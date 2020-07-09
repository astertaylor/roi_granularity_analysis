# -*- coding: utf-8 -*-
"""
Created on Tue Jul  7 17:41:09 2020

@author: aster
"""

# -*- coding: utf-8 -*-
"""
Created on Thu Jun 25 15:45:10 2020

Modified from process_cuttle_python.py created by ARK/DK

Takes input ROIs and RAW image and produces comparison graphs of the FFT
granularity analyis.

Note that this process does not account for camera spectral sensitivity in the 
course of its analysis. However, as part of the process, it is converted into 
a grayscale image via cv2.

ROIs are made in ImageJ. this analysis can also be performed with a set of points
provided in some other method, though you'd have to modify the import sequence.

@author: Aster Taylor
"""

#importing modules
import os
import argparse
import numpy as np
import matplotlib.pyplot as plt
import cv2
from read_roi import read_roi_zip
from lmfit import Model
import rawpy
from synthesis import synthesis_main

def parse_args():
    parser = argparse.ArgumentParser(description='Perform granularity analysis')
    parser.add_argument('-i', '--input_file', type=str, required=True, help='Path to the input image', nargs='+')
    parser.add_argument('-r', '--roi_file', type=str, required=False, help='ROI location', default = None)
    parser.add_argument('-o', '--out_path', type=str, required=False, help='Output folder location', default = None)
    parser.add_argument('-c', '--control_style', type=str, required=False, help='Style of controlling', default = 'mean')
    parser.add_argument('-f', '--fill_val', type=int, required=False, help='Fill value of control', default = 255)
    parser.add_argument('-n', '--NumBands', type=int,  required=False, default=7, help='Number of bands in granularity')
    parser.add_argument('-s','--save_filters', dest='save_filters', action='store_true')
    parser.add_argument('-d','--divide_roi', type = float,required=False, default=1, help='Shrink the ROIs by this value')
    parser.add_argument('-m','--band_method', type=str, required=False, default='gaussian-x', help='Method of creating masks')
    parser.add_argument('-a','--band_arguments', type=float, nargs=6, required=False, default=[500,169,340,0.50,650,-1], help='Constants used in band-making: amplitude, sigmax, sigmay (Gaussian) exponential for decrease, x-radius, y-radius')
    args = parser.parse_args()
    if args.roi_file == None:
        roi_list = []
        for arg in args.input_file:
            roi_list.append(arg.split('.')[0]+".zip")
        args.roi_file = roi_list
    if args.out_path == None:
        out_list = []
        for arg in args.input_file:
            out_list.append(arg.split('.')[0])
        args.out_path = out_list
    return args


def open_file(image_path, roi_path):
    #import ROIs as dictionary
    print("ROI path:",roi_path)
    try: rois = read_roi_zip(roi_path)
    except: 
        print("No ROI, transfomring whole image")
        rois = None
        
    #import image as np array
    try: 
        image = rawpy.imread(image_path)
        image = image.postprocess()
    except: 
        image = cv2.imread(image_path)
    print ("Importing Image "+image_path.split('/')[-1])
    
    #convert to grayscale
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    print ("Converting to grayscale")
    return(gray,rois)

def create_dirs(out_path, save):
    #creating directories for the files to go into
    try: os.mkdir(out_path)
    except OSError: print ("Creation of the directory failed, already exists")
    try: os.mkdir(out_path+"/Images")
    except OSError: print ("Creation of the directory failed, already exists")
    try: os.mkdir(out_path+"/Control_Images")
    except OSError: print ("Creation of the directory failed, already exists")
    try:os.mkdir(out_path+"/Output")
    except OSError: print ("Creation of the directory failed, already exists")   
    try: os.mkdir(out_path+"/Control_Output")
    except OSError: print ("Creation of the directory failed, already exists")
    try: os.mkdir(out_path+"/Adjusted_Output")
    except OSError: print ("Creation of the directory failed, already exists")
    if save: 
        try: os.mkdir(out_path+"/Filters")
        except OSError: print ("Creation of the directory failed, already exists")
    print ("Continuing...")
 
def find_bounds(rois):
    #set upper right and lower left pixels to cut down to
    #note that this usage prevents interimage comparison. However, this was 
    #already removed via issues of distance. 
    if rois == None: return(None)
    max_width = 0
    max_height = 0
    for ind1 in rois:
        if max(rois[ind1]['x'])-min(rois[ind1]['x'])>max_width:
            max_width = max(rois[ind1]['x'])-min(rois[ind1]['x'])
        if max(rois[ind1]['y'])-min(rois[ind1]['y'])>max_height:
            max_height = max(rois[ind1]['y'])-min(rois[ind1]['y'])
    print("Size:",max(max_width,max_height))
    
    return(max(max_width,max_height)) #kept square for ease of consideration

def shrink_roi(rois,constant):
    for ind in rois:
        roi = rois[ind]
        for i in range(roi['n']):
            roi['x'][i]=int(roi['x'][i]*constant)
            roi['y'][i]=int(roi['y'][i]*constant)
        rois[ind]=roi
    print("Shrunk ROI by:", constant)
    return(rois)
    
def crop_image(gray,roi,size):
    #create mask setup
    mask=np.zeros(gray.shape, dtype=np.uint8)
    
    roi_ul_x = min(roi['x'])
    roi_ul_y = min(roi['y'])
    roi_lr_x = max(roi['x'])
    roi_lr_y = max(roi['y'])
    print(roi_ul_x,roi_ul_y)
    print(roi_lr_x,roi_lr_y)
    width = int(roi_lr_x-roi_ul_x)
    height = int(roi_lr_y-roi_ul_y)
    
    centerX = np.round(width/2)
    centerY = np.round(height/2)
    
    center = np.round(size/2)
  
    #prepare points for ROI
    points = np.empty((roi['n'],2))
    for i in range(roi['n']):
        points[i]=np.array([roi['x'][i],roi['y'][i]])
        
    points = np.array(points,dtype=np.int32) #fillPoly() requires int32
     
    print("Filling in ROI...")
    cv2.fillPoly(mask,[points],255) #fills in the ROI with 255
    
    #create masked image and save to dictionary
    print("Masking...")
    m_img = cv2.bitwise_and(gray,mask)
    
    m_img = m_img[roi_ul_y:(roi_ul_y+height), roi_ul_x:(roi_ul_x+width)]
    print("Padding...")
    pad = np.zeros((size,size),dtype=np.uint8)
    for i in range(height):
        for j in range(width):
            deltX = int(centerX-j)
            deltY = int(centerY-i)
            offsetX = int(center-deltX)
            offsetY = int(center-deltY)
            pad[offsetY,offsetX]=m_img[i,j]
    m_img = pad
    #crop down to ROI rectangle
    
    return(m_img, mask)
    
def perform_fft(m_img,roi):
        
    #change to float32 for fft                                    
    m_img = np.float32(m_img)
    
    #transform to weber contrast
    if roi==None: mean_img = np.mean(m_img)
    else: mean_img = nan_mean(m_img,roi)
    print(mean_img)
    
    weber = (m_img-mean_img)/mean_img
    
    # 2D FFT and power spectrum
    print("Performing Standard FFT...")
    fft = np.fft.fft2(weber)
    fft_centered = np.fft.fftshift(fft)
    spectrum = np.real(fft_centered * np.conj(fft_centered))
    
    return(fft,spectrum)
  
'''
Because of the odd shape of the cutout images, here we compute the spectrum 
for an identical region, but instead of the animal or substrate the data
within the mask is composed of 0 outside the cutout and 255 inside.
Through experiments, which are commented out,the spectrum is identical no matter
what constant is used. This spectrum is also saved, and the ffts are subtracted,
before being converted into the spectrum and saved as well. spectrum_mod is
what is used for the visualizations. In addition, because of the radiant nature
of the artifacts, our elliptical interpretation into 2d allows us to be reasonably 
confident that there are no major effects due to these artefacts. 

'''
      
def control_creator(style,fill,gray,mask,roi,size):
    roi_ul_x = min(roi['x'])
    roi_ul_y = min(roi['y'])
    roi_lr_x = max(roi['x'])
    roi_lr_y = max(roi['y'])
    width = int(roi_lr_x-roi_ul_x)
    height = int(roi_lr_y-roi_ul_y)
    
    centerX = np.round(width/2)
    centerY = np.round(height/2)
    
    center = np.round(size/2)
    pattern = False
    if style == 'mean':
        fill_val = nan_mean(gray,roi)
        pattern = True
    if style == 'standard':
        fill_val = fill
        pattern = True
    if pattern == True:
        cont = np.full(gray.shape, fill_val,dtype=np.uint8) #cutout filled with value        
        print("Masking control...")
        control = cv2.bitwise_and(cont,mask) #masks control image
        control = control[roi_ul_y:(roi_ul_y+size), roi_ul_x:(roi_ul_x+size)] #crops control image
        print("padding")
        pad = np.zeros((size,size),dtype=np.uint8)
        for i in range(height):
            for j in range(width):
                deltX = int(centerX-j)
                deltY = int(centerY-i)
                offsetX = int(center-deltX)
                offsetY = int(center-deltY)
                pad[offsetY,offsetX]=control[i,j]
        control = pad
        control = np.float32(control) 
    if style == 'reflection':
        #as-of-yet unfinished
        reflect = True    
    return(control)

def save_image(image,out_path,folder,name,image_class):
    if image_class=='image':
        cv2.imwrite(out_path+"/"+folder+"/"+name+".png",image)
    elif image_class=='figure':
        #saves fourier transform spectrum to file, then clears canvas
        plt.figure(1)
        plt.imshow(np.log(1+np.abs(image)))
        plt.savefig(out_path+"/"+folder+"/"+name+"_output.png")
        plt.clf()

def nan_mean(m_img, mask):
    m_img_nan = np.where(not mask,np.nan,m_img)
    return(np.nanmean(m_img_nan))

def subtract_control(fft,fft_cont):            
    print("Creating modified FFT...")
    best_score = np.abs(np.mean(fft-fft_cont))
    best_const = 1
    for i in np.linspace(-2,2,num=200):
        test = fft-(i*fft_cont)
        print(np.mean(np.abs(test)))
        if np.mean(np.abs(test))<best_score:
            best_score = np.mean(np.abs(test))
            best_const = i
                    
    print("Constant Chosen for Controlling: ", best_const)
    fft_mod = fft-(best_const*fft_cont)
    fft_centered_mod = np.fft.fftshift(fft_mod)
    spectrum_mod = np.real(fft_centered_mod *np.conj(fft_centered_mod))
    
    return(fft_mod,spectrum_mod)
            
def delete_central_points(spectrum, radius):
    height, width = spectrum.shape #take shape
    centerX=np.round((width)/2) 
    centerY=np.round((height)/2)
    X=np.linspace(centerX-width,centerX+width,width) #creates coordinates
    Y=np.linspace(centerY-height,centerY+height,height)[:,None]
    cutout = ((X-centerX)**2+(Y-centerY)**2)>radius**2
    spectrum_mod = cutout*spectrum
    
    return(spectrum_mod)
            
  
            
            

'''
Here we now convert the spectra to 2d via an elliptical summation strategem.
These are plotted together to illustrate their similarity or difference.

It is in its own for-loop to allow the plots to overlap, since the one 
above clears the figure. 

'''

    
    
def gauss2d(xy,amp,x0,y0,sigx, sigy):
    x,y=xy
    inner1 = (x-x0)**2/(2*sigx**2)
    inner2 = (y-y0)**2/(2*sigy**2)
    return amp*np.exp(-(inner1+inner2))
    
def make_bands(constants, band_method, size, NumBands):
    #prepares structures for analysis
    if size==None: return(-1)
    BandMasks = np.zeros((size, size, NumBands))
    
    amp,sigX,sigY,expon,radX,radY = constants
            
    #defines center of structure
    center=np.round((size)/2) 
    
    Bands = np.arange(NumBands,0,-1)

      
    if band_method == 'linear':
        #Use linear scaling (not recommended, energy is too concentrated in center)
        RadiiX=(np.arange(NumBands)+1)*((radX)/(NumBands))
        print(RadiiX)
        if radY ==-1: RadiiY = RadiiX
        else: RadiiY=(np.arange(NumBands)+1)*((radY)/(NumBands))
    
    elif band_method == 'exponential':
        #Use exponential scaling, defines radii for ellipses
        RadiiX = 2*radX*np.power(expon,Bands)
        print(RadiiX)
        if radY ==-1: RadiiY = RadiiX
        else: RadiiY = 2*radY*np.power(expon,Bands)
        
    elif band_method == 'gaussian-x':
        RadiiX = (radX/expon)* np.power(expon,Bands) #Radii based on exponential radius
        print(RadiiX)
        Heights = gauss2d((center+RadiiX,(center*np.ones(NumBands))),amp,center,center,sigX,sigY)

        
    elif band_method == 'gaussian-z':
        Heights = amp*(1-np.power(expon,Bands)) #Radii based on exponential height
        print(Heights)
        
    elif band_method == 'gaussian-fit':
        return('fit')

    X=np.linspace(center-size,center+size,size) #creates coordinates
    Y=np.linspace(center-size,center+size,size)[:,None]
    for i in np.arange(NumBands): #looping over all bands

        if 'gaussian' in band_method:
                if i == 0:
                    BandScreen = gauss2d((X,Y),amp,center,center,sigX,sigY) > Heights[i]
                else:
                    BandScreen1 = gauss2d((X,Y),amp,center,center,sigX,sigY)<Heights[i-1]
                    BandScreen2 = gauss2d((X,Y),amp,center,center,sigX,sigY)>Heights[i]
                    BandScreen = np.where(BandScreen1 & BandScreen2, True,False)
        
        else: 
            if i==0:
                #defines the band to be summed over
                BandScreen = (((X-center)/RadiiX[i])**2+((Y-center)/RadiiY[i])**2) <=1
            else:
                #also defines the band and appends the area 
                BandScreen1 = (((X-center)/RadiiX[i-1])**2+((Y-center)/RadiiY[i-1])**2) > 1 
                BandScreen2 = ((X-center)/RadiiX[i])**2+((Y-center)/RadiiY[i])**2 <=1
                BandScreen = np.where(BandScreen1 & BandScreen2, True,False)
        
        BandMasks[:,:,i] = BandScreen
    
    return(BandMasks)

def gaussian_fit(spectrum,constants,size):
    center=np.round((size)/2) 
                
    X=np.linspace(center-size,center+size,size) #creates coordinates
    Y=np.linspace(center-size,center+size,size)[:,None]
    
    #FIND BEST-FIT GAUSSIAN USING MODEL
    gmodel = Model(gauss2d, independent_vars = ['x','y'])
    weights = np.where(spectrum==0,0,1)
    print(weights)
    result = gmodel.fit(spectrum,x=X, y=Y, amp = np.max(spectrum), x0=center, y0=center, sigX =1, sigY = 1)
    print(result.fit_report())
    
    return(result.fit_report())
            
            
def band_energies(spectrum,BandMasks,NumBands):
    band_energy=np.zeros(NumBands)
    for i in np.arange(NumBands):
        band_energy[i] = (np.sum(BandMasks[:,:,i] * spectrum))
        print("Band %d Complete"% (i))
    band_energy = band_energy/sum(band_energy)
        
    #plotting the band energy for each band.
    plt.figure(2)
    plt.plot(band_energy)
    print("Bands computed")
    plt.ylabel("Relative power")
    plt.xlabel("Granularity Band Index")
    
    return(band_energy)

def reverse_calculate(masked_img,NumBands, BandMasks, fft_mod,size):
        print("Saving reverse FFTs...")
        filtered_images = np.zeros((size, size * (NumBands + 1))) #creates filters
        filtered_images[:, 0:size] = masked_img/255
        for i in np.arange(NumBands):
            filtered_fft = np.fft.ifftshift(BandMasks[:,:,i] * fft_mod)
            filtered_image = np.real(np.fft.ifft2(filtered_fft)) #reverse fft
            offset = (size * (i + 1)) #offsets image
            filtered_images[:, offset:(offset+size)] = filtered_image + 0.5
        filtered_images_small=filtered_images
        
        #resizes and adjusts images
        filtered_images_small_u8 = (filtered_images_small * 200)
        filtered_images_small_u8[filtered_images_small_u8 > 255] = 255
        filtered_images_small_u8[filtered_images_small_u8 < 0] = 0
        filtered_images_small_u8 = np.uint8(filtered_images_small_u8)
        print("Reverse FFTs Saved")
        
        #saves pure inverse
        reverse = np.fft.ifftshift(fft_mod)
        reverse = 20*np.real(np.fft.ifft2(reverse))
        
        return(filtered_images_small_u8,255*reverse/np.max(reverse))
    
def find_rectangle(mask,size):
    center = np.round(size/2)
    mask = np.where(mask!=0,255,0)
    for i in np.arange(np.round(size/2),0,-1):
        rectangle = mask[int(center-i):int(center+i),int(center-i):int(center+i)]
        if np.max(rectangle)==np.min(rectangle)==255: 
            print("Dimensions of inner square:", i)
            return(i)
        
    return(None)
  
def main():
    args = parse_args()
    control_style = args.control_style
    fill_val = args.fill_val
    constants = args.band_arguments
    NumBands = args.NumBands
    save = args.save_filters
    if save == True: print("Save is True")
    for in_file in args.input_file:
        if type(args.roi_file)==list: roi_loc = args.roi_file[args.input_file.index(in_file)]
        else: roi_loc = args.roi_file
        gray,rois = open_file(in_file,roi_loc)
        create_dirs(args.out_path[args.input_file.index(in_file)],save)
        out_path = args.out_path[args.input_file.index(in_file)]
        
        rois = shrink_roi(rois,args.divide_roi)
        
        size = find_bounds(rois)
        if size == None: size = gray.shape[0]
        
        if args.control_style == 'texture':
            BandMasks = make_bands(constants, args.band_method, min(size,128), NumBands)
        else: BandMasks = make_bands(constants, args.band_method, size, NumBands)

        
        if rois==None:
            fft_none,spectrum_none = perform_fft(gray,None)
            save_image((spectrum_none+1),out_path,"Output","baseline",'figure')
            band_energies((spectrum_none+1), BandMasks, NumBands)
            plt.figure(2)
            plt.savefig(out_path+"/baseline_granularity.png")
            continue
        
        labels = []
        for ind in rois:
            print ("Now working on "+ind)
            roi = rois[ind]
            m_img,mask = crop_image(gray,roi,size)
            if m_img.shape[0]==0 or m_img.shape[1] == 0:
                continue
            save_image(m_img,out_path,"Images",ind,'image')
            
            fft,spectrum = perform_fft(m_img, roi)
            save_image(spectrum,out_path,"Output",ind,'figure')
            
            if args.control_style != 'texture':
                control = control_creator(control_style, fill_val, gray, mask, roi, size)
                save_image(control,out_path,"Control_Images", ind+"_control",'image')
            
                fft_cont,spectrum_cont = perform_fft(control,roi)
                save_image(spectrum_cont,out_path,"Control_Output",ind+"_control",'figure')
                
                fft_mod,spectrum_mod = subtract_control(fft,fft_cont)
                save_image(spectrum_mod,out_path,"Adjusted_Output",ind+"_adjusted",'figure')
                
                print("Saved modified "+ind)
                
                if save:
                    filtered, reverse = reverse_calculate(m_img, NumBands, BandMasks, fft_mod, size)
                    save_image(filtered, out_path, "Filters", ind+"_filtered_images",'image')
                    save_image(reverse, out_path, "Filters", ind+"_reverse_image",'image')
            
                
            else:
                center = np.round(size/2)
                rect = find_rectangle(m_img,size)
                if rect == None:
                    print("Cannot find rectangle within polygon")
                    break
                texture = m_img[int(center-rect):int(center+rect),int(center-rect):int(center+rect)]
                save_image(texture,out_path,"Control_Images",ind+"_rect_control",'image')
                if rect%2==0: kern = int(rect+1)
                else: kern = int(rect)
                synthesized_result = synthesis_main(texture,min(size,128),min(11,kern))
                save_image(synthesized_result,out_path,"Control_Images",ind+"_synth_control",'image')
                fft,spectrum_mod = perform_fft(synthesized_result,None)
                print(spectrum_mod)
                save_image(spectrum_mod,out_path,"Adjusted_Output",ind+"_synthesized",'figure')


            print("MOVING ON TO BAND ANALYSIS")
            
            band_energies(spectrum_mod, BandMasks, NumBands)
            labels.append(ind)
        
        if type(BandMasks) == int:
            gaussian_fit(spectrum,constants,size)
        
        plt.figure(2)
        plt.legend(labels)
        plt.savefig(out_path+"/granularity_bands.png")
        plt.clf()
        print("Granularity analysis saved")
        
        
    
    print("DONE")

if __name__ == '__main__':
    main()
    
#FIN
