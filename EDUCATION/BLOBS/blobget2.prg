The following example uses the BLOBGET() function to fetch a blob from the LONG_BLOB table and assign it to temprec->ImageData.

select into "nl:"
	lb.long_blob_id
	,lb.long_blob
from long_blob lb
plan lb where  lb.long_blob_id  = $ID
detail
    outbuf = " "
    imageDataSize = blobgetlen(lb.long_blob)  ;fetch full length of blob
    stat = MEMREALLOC(outbuf,1,build("C",imageDataSize)) ;resize using full length to fetch with one blobget call
    totlen = blobget(outbuf,0,lb.long_blob)
    temprec->ImageData = notrim(outbuf)
with rdbarrayfetch=1