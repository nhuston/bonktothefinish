# from PIL import Image

# size = (128, 128)

# for infile in sys.argv[1:]:
#     outfile = os.path.splitext(infile)[0] + ".thumbnail"
#     if infile != outfile:
#         try:
#             im = Image.open(infile)
#             im.thumbnail(size)
#             im.save(outfile, "JPEG")
#         except IOError:
#             print("cannot create thumbnail for", infile)

import os

def get_blog_names():
    names = set()
    for (dirpath, dirnames, filenames) in os.walk("../blog"):
        for name in filenames:
            blog_title = name.split(".")[0]
            names.add(blog_title)
    return list(names)

def article_name(str,names):
    matching_article_name = None
    for n in names:
        if str in n:
            return matching_article_name

    return matching_article_name

def rename_articles():
    article_names = get_blog_names()

    for (dirpath, dirnames, filenames) in os.walk("./"):
        for dn in dirnames:
            a_name = article_name(dn)
            year = a_name[0:4]
            os.rename(dn, year+"/"+a_name)

    
