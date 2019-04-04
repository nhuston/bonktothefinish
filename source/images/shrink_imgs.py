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
import shutil
import pdb
from PIL import Image

max_im_size = (1100, 1100)
big_thumb_size = (512,512)
small_thumb_size = (128,128)

def get_blog_names():
    names = set()
    for (dirpath, dirnames, filenames) in os.walk("../blog"):
        for name in filenames:
            blog_title = name.split(".")[0] # WILL NOT WORK if the blog title has a '.' in it
            names.add(blog_title)
    return list(names)

def article_name(str,names):
    for n in names:
        just_name = n[len("2017-06-10-"):] #this is an example date, use it to strip date away from name string -- +1 as the first number is inclusive

        if str == just_name:
            return n
    
    return None

def rename_articles():
    article_names = get_blog_names()

    for dn in os.listdir("./blog"):
        a_name = article_name(dn, article_names)
        if a_name is None or len(dn) == 4:
            print()
            print (dn)
        else:
            year = a_name[0:4]
            shutil.move("./blog/"+dn, "./blog/"+year+"/"+a_name)

def shrink_save(im, size, path):
    im.thumbnail(size) 
    print("Shrinking: "+ path)
    im.save(path, "JPEG")

def make_containing_folder_for(filename):
    path_parts = filename.split("/")
    path_parts = path_parts[0:len(path_parts)-1]
    path="/".join(path_parts)
    if not os.path.exists(path): #make thumb dir if needed
        os.makedirs(path)

def resize_images():
    print("Resizing Images")
    img_folder_path = "./source/images"
    full_size_img_path = img_folder_path+"/blog/full_size/"
    for (dirpath, dirnames, filenames) in os.walk(full_size_img_path):
        for infile in filenames:
            file_root = os.path.splitext(infile)[0]
            jpg_filename = file_root + ".jpg"
            outfile = dirpath + "/"+ jpg_filename

            need_resize = False
            try:
                im = Image.open(outfile) #will fail if image is not ".jpg" extension
            except:
                in_filename = dirpath+"/"+infile
                im = Image.open(in_filename)
                os.remove(in_filename)
                need_resize = True

            need_resize = need_resize or im.size[0] > max_im_size[0] or im.size[1] > max_im_size[1]# check to see if this image has been shrank before
            if need_resize:
                shrink_save(im, max_im_size, outfile)

            thumb_small_filename = outfile.replace("full_size","small_thumbnails",1)
            try: # check for existance of small thumbnail
                thumb = Image.open(thumb_small_filename)
            except:
                make_containing_folder_for(thumb_small_filename)                
                shrink_save(im.copy(), small_thumb_size, thumb_small_filename)

            thumb_big_dir = "./blog/big_thumbnails"
            thumb_big_filename = outfile.replace("full_size","big_thumbnails",1)
            try: # check for existance of thumbnail
                thumb = Image.open(thumb_big_filename)
            except:
                make_containing_folder_for(thumb_big_filename)                
                shrink_save(im.copy(), big_thumb_size, thumb_big_filename)

resize_images()

# rename_articles()
