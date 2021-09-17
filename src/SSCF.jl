module SSCF

using Dates
using Colors
using Mmap

"""SSCF Header data structure"""
struct SSCFHeader
    version :: Float32
    channels :: Integer
    samples :: Integer
    dt :: Float32
	
    function SSCFHeader(f::IOStream)
	magic = read(f, Float32)
	
	if magic != 1003.
	    error("Not a valid SSCF file. Wrong magic number.")
	end
	
	version = read(f, Float32)
	channels = read(f, Float32)
	samples = read(f, Float32)
	dt = read(f, Float32)
	
	return new(version, channels, samples, dt)
    end
end

"""Channel Information Record"""
struct ChannelInfo
    title :: String
    units :: String
    instrument :: String
    # aux1 :: String
    # aux2 :: String
    transform :: Int32
    color :: RGB
    # aux :: Vector{Float32}
	
    function ChannelInfo(f::IOStream)
	io = IOBuffer(read(f, 24), read=true, write=false, maxsize=24)
	title = strip(read(io, String))
		
	io = IOBuffer(read(f, 16), read=true, write=false, maxsize=16)
	units = strip(read(io, String))
		
	io = IOBuffer(read(f, 32), read=true, write=false, maxsize=32)
	instrument = strip(read(io, String))
		
	# skip unused aux fields
	skip(f, 32 + 32)
		
	transform = read(f, Int32)
	cc = read(f,Int32)
	color = RGB(
	    cc % 256 / 255.,
	    ((cc // 256) % 256) / 255.,
	    ((cc // (256*256)) % 256) / 255.
	)	
			
	# skip aux floats
	skip(f, 31*sizeof(Float32))
		
	return new(title, units, instrument, transform, color)
    end
end

"""Marker Table"""
struct MarkerTable
    samples :: Vector{Int32}
    code :: Vector{Char}
	
    function MarkerTable(raw::Array{Int32,1})
	samples = zeros(Int32, length(raw))
	code = Vector{Char}(undef, length(raw))
		
	for i in 1:length(raw)
            code[i], samples[i] = divrem(raw[i],1E6)
	end
		
	return new(samples, code)
    end
	
end


"""SSCF Footer Information"""
struct SSCFFooter
    timestamp :: DateTime
    remarks :: String
    markers :: MarkerTable
    channelinfo :: Vector{ChannelInfo}
    setup_path :: String
    setup_file :: String
	
    function SSCFFooter(f::IOStream, header::SSCFHeader)
	# skip auxiliary records (unused)
	skip(f, 10 * header.channels * sizeof(Float32))
		
	# date time
	day = read(f, Float32)
	month = read(f, Float32)
	year = read(f, Float32)
	hour = read(f, Float32)
	minute = read(f, Float32)
	second = read(f, Float32)
		
	stamp = DateTime(year, month, day, hour, minute, second)
		
	# remarks (part 1)
	io = IOBuffer(read(f, 240), read=true, write=false, maxsize=240)
	remarks = read(io, String)
		
	# markers
	marker_count = read(f, Int32)
	marker_data = Vector{Int32}(undef, marker_count)
	read!(f, marker_data)
	markers = MarkerTable(marker_data)
		
	# note markers
	marker_count = read(f, Int32)
	notemarkers = read(f, marker_count * 256)
	# TODO decode
		
	# check channel number
	channel_count = read(f, Int32)
	if channel_count != header.channels
	    error("Invalid SSCF file. Cannel count mismatch between header and footer.")
	end
		
	# channel info
	channelinfo = [ChannelInfo(f) for i in 1:header.channels]
		
	# user vars
	mdata = read(f, 50*sizeof(Float32))
	asize = read(f, Int32)
	aliases = read(f, asize)
	
	# setup info
	asize = read(f, Int32)
	if asize == 0
	    setup_path = ""
	    setup_file = ""
	elseif asize == 192
	    io = IOBuffer(read(f, 64), read=true, write=false, maxsize=64)
	    setup_file = read(io, String)
	    io = IOBuffer(read(f, 128), read=true, write=false, maxsize=128)
	    setup_path = read(io, String)
	else
	    error("Invalid SSCF file. Incorrect setup info size.")
	end
			
	# remarks (part 2)
	asize = read(f, Int32)
	io = IOBuffer(read(f, asize), read=true, write=false, maxsize=asize)
	remarks = remarks * read(io, String)
	
	return new(stamp, remarks, markers, channelinfo, setup_path, setup_file)
    end
end

"""Main SSCF File data structure"""
struct SSCFFile 
    path :: String
    data :: Matrix{Float32}
    header :: SSCFHeader
    footer :: SSCFFooter
	
    """Open file descriptor and read file contents

    Example Usage:
    >> sscf = open("test.exp") |> SSCFFile    
    """
    function SSCFFile(f::IOStream)
	header = SSCFHeader(f)
		
	# mem map
	data_size = header.channels * header.samples * sizeof(Float32)
	data = Mmap.mmap(f, Matrix{Float32}, (header.channels, header.samples))
		
	# skip to footer
	skip(f, data_size)
	footer = SSCFFooter(f, header)
	
	return new(f.name, data, header, footer)
    end

    """Open file given by filename

    Example Usage:
    >> sscf = SSCFFile("test.exp")
    """
    SSCFFile(filename::String)= open(filename) |> SSCFFile
end

"""Direct access for some header/footer data as properties

.samples - number of samples in file
.channels - number of data channels
.starttime - time of first sample
.endtime - time of last sample
.interval - sample interval rounded to msec precision
.times - vector of sample times
.markers - the marker table (type MarkerTable)
.remarks - remarks string
"""
function Base.getproperty(f::SSCFFile, v::Symbol)
	if v == :samples
    	    return f.header.samples
        elseif v == :times
            return f.starttime:f.interval:f.endtime
        elseif v == :starttime
            return f.endtime - (f.samples-1) * f.interval
        elseif v == :endtime
            return f.footer.timestamp
        elseif v == :interval
            return Millisecond(f.header.dt * 1000)
	elseif v == :channels
	    return f.header.channels
	elseif v == :markers
	    return f.footer.markers
	elseif v == :remarks
	    return f.footer.remarks
	else
	    return getfield(f, v)
	end
end

"""Index based access to data channels by name


    Example Usage:
    >> sscf = open("test.exp") |> SSCFFile    
    >> o2_a = sscf["O2_A"]
"""
function Base.getindex(collection::SSCFFile, key::String)
    index = findfirst([x.title == key for x in collection.footer.channelinfo])
    return collection.data[index,:]
end

end
