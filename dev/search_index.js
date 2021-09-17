var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = SSCF","category":"page"},{"location":"#SSCF","page":"Home","title":"SSCF","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for SSCF.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [SSCF]","category":"page"},{"location":"#SSCF.ChannelInfo","page":"Home","title":"SSCF.ChannelInfo","text":"Channel Information Record\n\n\n\n\n\n","category":"type"},{"location":"#SSCF.MarkerTable","page":"Home","title":"SSCF.MarkerTable","text":"Marker Table\n\n\n\n\n\n","category":"type"},{"location":"#SSCF.SSCFFile","page":"Home","title":"SSCF.SSCFFile","text":"Main SSCF File data structure\n\n\n\n\n\n","category":"type"},{"location":"#SSCF.SSCFFooter","page":"Home","title":"SSCF.SSCFFooter","text":"SSCF Footer Information\n\n\n\n\n\n","category":"type"},{"location":"#SSCF.SSCFHeader","page":"Home","title":"SSCF.SSCFHeader","text":"SSCF Header data structure\n\n\n\n\n\n","category":"type"},{"location":"#Base.getindex-Tuple{SSCFFile, String}","page":"Home","title":"Base.getindex","text":"Index based access to data channels by name\n\nExample Usage:\n>> sscf = open(\"test.exp\") |> SSCFFile    \n>> o2_a = sscf[\"O2_A\"]\n\n\n\n\n\n","category":"method"},{"location":"#Base.getproperty-Tuple{SSCFFile, Symbol}","page":"Home","title":"Base.getproperty","text":"Direct access for some header/footer data as properties\n\n.samples - number of samples in file .channels - number of data channels .starttime - time of first sample .endtime - time of last sample .interval - sample interval rounded to msec precision .times - vector of sample times .markers - the marker table (type MarkerTable) .remarks - remarks string\n\n\n\n\n\n","category":"method"}]
}