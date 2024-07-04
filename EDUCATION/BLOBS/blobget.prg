;The following example uses the BLOBGET() function to fetch a blob from the
;LONG_TEXT table. The blob is then broken up into 200 line segments and displayed.

select into $outdev
	bloblen = blobgetlen(l.long_text)
from long_text l
head report
        outbuf = " "
        retlen = 0
head l.long_text_id
        offset = 0
detail
        col 0 l.long_text_id "##########", bloblen "########"
	row +1
	retlen = 1
	stat = memrealloc(outbuf,1,build("C",bloblen))
	retlen = blobget(outbuf,offset,l.long_text)
	cnt = 0
	while (offset < bloblen and cnt < 100)
		cnt = cnt +1
        col 20, call print(substring(offset, 200,outbuf)), row+1
        offset = offset + 200
	endwhile
with rdbarrayfetch=1
	,maxcol=250
	,maxrec = 10