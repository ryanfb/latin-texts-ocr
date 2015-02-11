latin-texts-ocr
---------------

This is a repository for plaintext OCR processing results on Internet Archive works in the [latin-texts](https://github.com/dbamman/latin-texts) repo in `latin_to_annotate.txt` that have derivatives (i.e. PDFs) on IA but no existing OCR text. See [`missing_ids_200_pdfs.txt`](https://gist.github.com/cf4c5b45b706e4b17a81) or [its make target in my `classification` branch of the `latin-texts` repo](https://github.com/ryanfb/latin-texts/blob/classification/metadata/Makefile#L96).

Processing is being done with:

    TESSERACT_FLAGS="-l lat+eng+grc+deu" ~/source/ocrpdf/ocrpdf.sh "${i}.pdf"

Where ocrpdf.sh is a version of [this script](https://gist.github.com/ryanfb/f792ce839c8f26e972cf) modified to retain plaintext and hocr output.

The Latin Tesseract training file is [v0.1.0-alpha2](https://github.com/ryanfb/latinocr-lat/releases/tag/v0.1.0-alpha2) from my preliminary Latin OCR training process, Greek is [v2.0 from Nick White's Ancient Greek OCR](http://ancientgreekocr.org/). 

Languages were picked with:

    cut -d, -f 2 < djvus-language-confidence.txt|sort|uniq -c|sort -n

See: [`djvus-language-confidence.txt`](https://gist.github.com/ryanfb/cb6a4af5704c7b985045)
