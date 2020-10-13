/ PHE Coronavirus API library for kdb+/q
/ requires kdb+ v4.0 or above (for gzip decompression)
if[.z.K<4;'"requires kdb+ 4.0 or above"];

/ HTTP helper functions
\d .http

/URI escaping for non-safe chars, RFC-3986
hu:.h.hug .Q.an,"-.~"

/convert non strings to strings, escape non-safe chars
str:{enlist hu $[10=type x;x;string x]}

/encode a dictionary as a string e.g. URL encode
enc:{[d;fs;rs] /d:dictionary,fs:field separator,rs:record separator
  /split dictionary into keys & values and stringify
  k:str'[key d];v:str'[value d];
  /encode dictionary with field & record separators
  :rs sv fs sv' k,'v;
  }

/perform request & account for pagination
req:{[u] /u:URL (string)
	/request & parse JSON response
  d:.j.k .Q.hg u;
  /if no next URL, return the data
  if[10h<>type d[`pagination][`next];:d[`data]];
  /otherwise, grab the next url & join it's data onto this one
  :d[`data],.z.s .phe.baseurl,d[`pagination][`next];
 }

\d .phe

/base URL for PHE API requests
baseurl:"https://api.coronavirus.data.gov.uk"
/read cfg csv for use in cfgreq function
cfg:("S BSC";enlist",")0:`:cfg.csv

/preform a PHE request
req:{[d] /d:dict of params (filters & structure)
  /convert sturcture to json
  d:@[d;`structure;.j.j];
  /convert filters as necessary
  d:@[d;`filters;.http.enc[;"=";";"]];
  /send request & get data
  :.http.req baseurl,"/v1/data?",.http.enc[d;"=";"&"];
 }

/perform a PHE request using loaded config for which fields to grab, rename, cast
cfgreq:{[f] /f:dict of filters
  /perform request generating structure from config
  r:req `filters`structure!(f;exec (phename^name)!phename from cfg where enabled);
  /apply casts from config
  :![r;();0b;($),/:exec name!(cast,'name) from cfg where enabled,not null cast];
 }
