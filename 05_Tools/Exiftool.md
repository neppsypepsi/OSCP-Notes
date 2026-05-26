exiftool can:

- **Read metadata** from files
- **Write metadata** into files
- **Remove metadata**
- **Rename files based on metadata**


### **Key idea**

- Metadata = hidden fields inside a file
- You **cannot rename fields**
- You **can change, add, or delete values**

Format:
```code
FieldName : Value
```

### **Read metadata (recon)**
```bash
exiftool image.png
```
Used to find:

- Usernames
- Software
- Paths
- Comments

Possible Output:
```text
Creator Tool : Adobe Photoshop 2025
Artist       : nigel
GPS Latitude : 44.0521
```

### **Change one field**

```bash
exiftool -Artist="anonymous" image.png
```
> Put the value anonymous into the Artist field of image.png
### **Remove one field**
```bash
exiftool -GPSLatitude= image.png

or 

exiftool -GPSLatitude= -GPSLongLatitude= image.png 

```

### **Change multiple fields at once**
```bash
exiftool -Artist="anon" -CreatorTool="GIMP" image.png
```







Why this matters
## **1. Fraud detection**
Metadata can act as a **supporting signal**, not proof.
### **How it helps**

- **Timestamp anomalies**
    
    - Photo claims “brand new item listed today”
    - EXIF shows image created **5 years ago**
    
- **Location mismatches**
    
    - Seller account: Oregon
    - EXIF GPS: China / warehouse region
    
- **Camera/software consistency**
    
    - Thousands of sellers uploading “unique” items
    - All images show same camera model + software version

### **What this indicates**

- Stock images
- Drop-shipping misrepresentation
- Coordinated fraud rings




Personal Note:

If you have a downloaded image from someplace some where, you can remove the metadata that is revealing that the image was downloaded from some place or generated, and then add what you want it to say. Perhaps you can inspect a real file of a picture you have taken and then replicate it on the file you 'stole'. 
