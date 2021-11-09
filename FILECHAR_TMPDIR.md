# TEMPORARY DOWNLOAD STORAGE 

When files are ingested CurateND, they are scanned for viruses with [CLAMAV](https://www.clamav.net), and the file size and MIME type are gleaned using [FITS](https://projects.iq.harvard.edu/fits/home). As the files stored in CurateND have become larger, it is no longer possible to do this in memory. This document descibes how temporary file download storage for File Chracterization is managed.

For this discussion, we assume that large files are ingested using the [Batch Ingest](https://github.com/ndlib/curatend-batch) system , reside in the [Bendo](https://github.com/ndlib/bendo) storage layer, that the Fedora Object descibing this file is an indirect datastream, and that the Bendo URI to the ingested file is stored in the datastream's *dsLocation* attribute.

The current implemtation asssumes that the download storage is accessible as a local file sytem on the VM or RC2 instance where the worker process doing characterization is running.

## Configuration

In the Ansible Configuration code for CurateND, the tmmdir to use for downloads is [here](https://github.com/ndlib/dlt-ansible/blob/master/group_vars/curate-r7-workers), and is defined in the attribute ***curate\_worker\_tmpdir***. At present, this directory is assumed to have the smae base name on all of the Curate Workers, for instance ***/global/data/downloads***, with the environment of the work appended, such as ***/global/data/downloads/prep***.

The ansible code provides this value to CurateND in the application.yml as CURATE\_WORKER\****_TMPDIR,
and is avaialble to the Rails app vi Figaro as Figaro.env.curate\_worker\_tmpdir

## What You Should See

When File characterization is run, the file will be downloaded from bendo to the TempDir via HTTP using the Down ruby gem, and open_uri underneath. The Charcterization worker will override the default system temdir direction defined in **TMPDIR** with the value of CURATE\_WORKER__TMPDIR, using a ./tmp folder with that. During the downlaod, you should see the open_uri tempfiler.

For example, lets say you're downlaoding the file **json_archive_gov.zip**. Initially, you'll see the open_uri temp file

> ls -l /global/data/doenloads/staging/tmp
> 
> -rw------- 1 app app 13862142464 Nov  9 10:22 open-uri20211109-2311-1ckczkd

When the download has finished the temp file is moved and renamed

> ls
> 
> ./json_archive_gov.zip

At point, you should be able to see FITs being run against that file.

>  ps -ef | grep fits
>  ****
> app       2401  2311 99 10:23 ?        00:03:55 java -classpath ....
> **
>  edu.harvard.hul.ois.fits.Fits -i **/global/data/downloads/staging/json\_archive_gov.zip**

When FITS is finished, the temp file should be removed.

##Troubleshooting

If File Characterization did not run succeed, the file type for it on its CurateND works page is usually "Calculating...". If this is the case, try manually recharacterizing by going to the file's Detail page for the Works page and clicking on the "Characterize" button. You should see the above process happen. If not, go to the CurateND -> Repository Administration ->Resque Queue web page, and see if there is a recented entry in the "failed" section, then look at the stack trace. 
