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
import sys, getopt
import numpy as np
import matplotlib.pyplot as plt
import cv2
from read_roi import read_roi_zip
import rawpy

try: ind_r=sys.argv.index("-r") #find and extract end of the input file chain
except: ind_r=None
try: ind_o=sys.argv.index("-o")
except: ind_o=None
try: ind_n=sys.argv.index("-n")
except: ind_n=None
try: ind_s=sys.argv.index("-s")
except: ind_s=None
try: end = min(i for i in [ind_r,ind_o,ind_n,ind_s] if i is not None)
except: end=-1
if end==-1: args = sys.argv[sys.argv.index("-i")+1:]
else: args = sys.argv[sys.argv.index("-i")+1:end] #extracted input file batch

print(args)
if args[0] == '.CR2' or args[0] == '.NEF':
    print("Batch Making...")
    cur_dir = os.getcwd()
    path_list = [f.path for f in os.scandir(cur_dir) if f.is_dir()]
    
    #iterate to find all directories
    for dir_name in path_list:
        i=path_list.index(dir_name)
        try: path_list=path_list+[f.path for f in os.scandir(dir_name) if f.is_dir()]
        except: continue
    
    #iterate to find all files
    file_names=[]
    for dir_name in path_list:
        path_mod = os.listdir(dir_name)
        for i in range(len(path_mod)):
            path_mod[i]=dir_name+'/'+path_mod[i]
        file_names=file_names+path_mod
    
    #file all RAW files
    for in_name in file_names:
        if args[0] in in_name:
            print(in_name)
            args.append(in_name)
        else: continue
    
    #create list of RAW files only
    args = args[1:]
    
print("Arguments to be run through: ",args)
print("Processing arguments...")
try: opts, arg_worthless = getopt.getopt(sys.argv[1:],"hi:o:sr:n:",["infile=","odir=","roifile=",
                                                    "numbands="])
except getopt.GetoptError: #error in input
   print('roi_granularity_comparison.py -i <inputfile> -r <roifile> -o <outputdir> -n <bandnumber>')
   sys.exit(2)
NumBands=7 #setting default
save = False #setting default
ROI_check = True
for opt,arg in opts: #setting out-directory
    if opt == '-h': #help return
       print('roi_granularity_comparison.py -i <inputfile> -r <roifile> -o <outputdir> -n <bandnumber>')
       sys.exit()
    elif opt in ("-n", "--bandnumber"): #setting number of bands
       NumBands = int(arg)
    elif opt == "-s": #setting whether granularity images should be saved
        save = True
        print("SAVE Changed to True")
        
for arg in args: #looping through batch files
    
    print(arg)
    image_path = arg
    print("OPTS:",opts)
    out_path=image_path[:-4] #setting default
    roi_path=image_path[:-4]+".zip" #setting default
    for opt,arg1 in opts: #setting out-directory
        if opt in ("-o", "--ofile"):
           out_path = arg1
        elif opt in ("-r", "--roifile"): #setting input ROI
           roi_path = arg1

    #import ROIs as dictionary
    print(roi_path)
    try: rois = read_roi_zip(roi_path)
    except: 
        print("No ROI")
        ROI_check = False
        
    #import image as np array
    try: 
        image = rawpy.imread(image_path)
        image = image.postprocess()
    except: 
        image = cv2.imread(image_path)
    print ("Importing Image "+image_path.split('/')[-1])
    print(image.shape)
    break
    
    #convert to grayscale
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    print ("Converting to grayscale")
    
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
    
    #Create masks dictionary
    masks = {}
    #dictionary for storing masked images
    masked_imgs = {}
    #dictionary for storing spectrums
    spectrums = {}
    #list for storing labels for the granularity graph
    labels = []
    #dictionary for storing centered fft for save
    fft_mods = {}
    
    #set upper right and lower left pixels to cut down to
    #note that this usage prevents interimage comparison. However, this was 
    #already removed via issues of distance. 
    max_width = 0
    max_height = 0
    for ind1 in rois:
        if max(rois[ind1]['x'])-min(rois[ind1]['x'])>max_width:
            max_width = max(rois[ind1]['x'])-min(rois[ind1]['x'])
        if max(rois[ind1]['y'])-min(rois[ind1]['y'])>max_height:
            max_height = max(rois[ind1]['y'])-min(rois[ind1]['y'])
    print(max_width,max_height)
    print("Beginning Fast Fourier Transform...")
    if ROI_check == True:
        for ind in rois: #loop over all ROIs, produce result
            print ("Now working on "+ind)
            
            
            #DELETE LATER
            for i in range(rois[ind]['n']):
                rois[ind]['x'][i]=int(rois[ind]['x'][i]*256/3000)
                rois[ind]['y'][i]=int(rois[ind]['y'][i]*256/3000)
            
            
            #create mask setup
            masks[ind]=np.zeros(gray.shape, dtype=np.uint8)
          
            
            roi_ul_x = min(rois[ind]['x'])
            roi_ul_y = min(rois[ind]['y'])
            roi_lr_x = max(rois[ind]['x'])
            roi_lr_y = max(rois[ind]['y'])
            print(roi_ul_x,roi_ul_y)
            print(roi_lr_x,roi_lr_y)
          
            #prepare points for ROI
            points = np.empty((rois[ind]['n'],2))
            for i in range(rois[ind]['n']):
                points[i]=np.array([rois[ind]['x'][i],rois[ind]['y'][i]])
                
            points = np.array(points,dtype=np.int32) #fillPoly() requires int32
             
            print("Filling in ROI...")
            cv2.fillPoly(masks[ind],[points],255) #fills in the ROI with 255
            
            #create masked image and save to dictionary
            print("Masking...")
            m_img = cv2.bitwise_and(gray,masks[ind])
            #crop down to ROI rectangle
            masked_imgs[ind]=m_img = m_img[roi_ul_y:(roi_ul_y+max_height), roi_ul_x:(roi_ul_x+max_width)]
            m_img_nan = np.where(not rois[ind],np.nan,m_img)
            pattern_mean = np.nanmean(m_img_nan)
            if m_img.shape[0]==0 or m_img.shape[1] == 0:
                continue
            cv2.imwrite(out_path+"/Images/"+ind+'.png',m_img)
                 
            #change to float32 for fft                                    
            m_img = np.float32(m_img)
            
            #transform to weber contrast
            mean_img = np.mean(m_img[:])
            weber = (m_img-mean_img)/mean_img
            
            # 2D FFT and power spectrum
            print("Performing Standard FFT...")
            fft = np.fft.fft2(weber)
            fft_centered = np.fft.fftshift(fft)
            spectrum = np.real(fft_centered * np.conj(fft_centered))
            
            #saves fourier transform spectrum to file, then clears canvas
            plt.imshow(np.log(np.abs(spectrum)))
            print(type((spectrum)))
            print(spectrum.shape)
            plt.savefig(out_path+"/Output/"+ind+"_output.png")
            plt.clf()
            print("Saved %s standard"% (ind))
            
            
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
            
            #commented-out experiments on creation of the control
            #img_nan = np.where(m_img==0,np.nan,m_img) #definition used for next line
            #cont = np.full(gray.shape, img_nan[~np.isnan(img_nan)].mean(),dtype=np.uint8) #mean, discounting 0s 
            #cont = np.full(gray.shape, np.max(m_img).mean(),dtype=np.uint8) #mean of the image
            cont = np.full(gray.shape, pattern_mean,dtype=np.uint8) #cutout filled with 255
            print("Moving on to control")
        
            print("Masking control...")
            control = cv2.bitwise_and(cont,masks[ind]) #masks control image
            control = control[roi_ul_y:(roi_ul_y+max_height), roi_ul_x:(roi_ul_x+max_width)] #crops control image
            cv2.imwrite(out_path+"/Control_Images/"+ind+'_control.png',control) #saves image
            control = np.float32(control) #turns to float
            
            #transfoms to weber contrast
            mean_control = np.mean(control[:])
            weber_cont = (control-mean_control)/mean_control
            
            #takes fft and transforms to spectrum
            print("Performing control FFT...")
            fft_cont = np.fft.fft2(weber_cont)
            fft_centered_cont = np.fft.fftshift(fft_cont)
            spectrum_cont = np.real(fft_centered_cont * np.conj(fft_centered_cont))
                
            #saves spectrum to desired location and clears figure
            plt.imshow(np.log(np.abs(spectrum_cont)))
            plt.savefig(out_path+"/Control_Output/"+ind+"_Control_output.png")
            plt.clf()
            print("Saved %s control"% (ind))
                
            #subtracts the ffts from each other and turns them into spectrums
            print("Creating modified FFT...")
            best_score = np.mean(np.abs(fft-fft_cont))
            best_const = 1
            print(int(np.max(fft)))
            for i in np.linspace(-2,2,num=200):
                test = fft-(i*fft_cont)
                print(np.mean(np.abs(test)))
                if np.mean(np.abs(test))<best_score:
                    best_score = np.mean(np.abs(test))
                    best_const = i
                    
            print("Constant Chosen for Controlling: ", best_const)
            fft_mod = fft-(best_const*fft_cont)
            fft_centered_mod = fft_mods[ind]=np.fft.fftshift(fft_mod)
            spectrum_mod = np.real(fft_centered_mod *np.conj(fft_centered_mod))
            
            '''#DELETE MOST CENTRAL POINTS
            height, width = spectrum.shape #take shape
            centerX=np.round((width)/2) 
            centerY=np.round((height)/2)
            X=np.linspace(centerX-width,centerX+width,width) #creates coordinates
            Y=np.linspace(centerY-height,centerY+height,height)[:,None]
            cutout = ((X-centerX)**2+(Y-centerY)**2)>10**2
            spectrum_mod = cutout*spectrum_mod'''
            
            #saves the modified spectrum into the dictionary
            spectrums[ind]=spectrum_mod
            
            #saves modified spectrum and clears the figure
            plt.imshow(np.log(np.abs(spectrum_mod)))
            plt.savefig(out_path+"/Adjusted_Output/"+ind+"_adjusted_output.png")
            plt.clf()
            
            print("Saved modified "+ind)
            
            '''
            Here we now convert the spectra to 2d via an elliptical summation strategem.
            These are plotted together to illustrate their similarity or difference.
            
            It is in its own for-loop to allow the plots to overlap, since the one 
            above clears the figure. 
            
            '''
    else:
         #change to float32 for fft
        m_img = gray
        m_img = np.float32(m_img)
        
        #transform to weber contrast
        mean_img = np.mean(m_img[:])
        weber = (m_img-mean_img)/mean_img
        
        # 2D FFT and power spectrum
        print("Performing Standard FFT...")
        fft = np.fft.fft2(weber)
        fft_centered = np.fft.fftshift(fft)
        spectrum = np.real(fft_centered * np.conj(fft_centered))
        print(np.max((np.abs(spectrum))))
        print(np.where(np.abs(spectrum)==np.max(np.abs(spectrum))))
        
        #saves fourier transform spectrum to file, then clears canvas
        plt.imshow(np.log(np.abs(spectrum)))
        plt.savefig(out_path+"/Output/"+arg.split('/')[-1][:-4]+"_output.png")
        plt.clf()
        print("Saved standard FFT")
            
    print("MOVING ON TO BAND ANALYSIS")
    
    #dictionary for storing energies
    band_energies = {}
    
    def gauss2d(x,y,amp,x0,y0,sigx, sigy):
        #x,y=xy
        inner1 = (x-x0)**2/(2*sigx**2)
        inner2 = (y-y0)**2/(2*sigy**2)
        return amp*np.exp(-(inner1+inner2))
    
    if ROI_check == True:
        for ind in rois: #here we do the masking and the reverse FFT
            labels.append(ind) #builds up the label list
            
            # create elliptical masks
           
            try: spectrum = spectrums[ind] #define spectrum for ease of reference
            except KeyError: continue 
            
            height, width = spectrum.shape #take shape
            
            #prepares structures for analysis
            BandMasks = np.zeros((height, width, NumBands))
            BandAreas = [] #note that this is not used here as of right now
            band_energy = np.zeros(NumBands)
            
            #defines center of structure
            centerX=np.round((width)/2) 
            centerY=np.round((height)/2)
            
            #Use linear scaling (not recommended, energy is too concentrated in center)
            #RadiiX=(np.arange(NumBands)+1)*((width)/(NumBands))
            #print(np.max(RadiiX)*2)
            #RadiiY=(np.arange(NumBands)+1)*((height)/(NumBands))
        
            #Use exponential scaling, defines radii for ellipses
            #Bands = np.arange(NumBands,0,-1)
            #RadiiX = 2*width*np.power(1/2,Bands)
            #RadiiY = 2*height*np.power(1/2,Bands)
            
            #Gaussian curve
            Bands = np.arange(NumBands,0,-1)
            print(Bands)
            amp = 500
            sigx,sigy = 169,340
            
            #Heights = amp*(1-np.power(0.4,Bands)) #Radii based on exponential height
            
            RadiiX = 455* np.power(0.55,Bands) #Radii based on exponential radius
            print(RadiiX)
            Heights = gauss2d(RadiiX+centerX,centerY,amp,centerX,centerY,sigx,sigy)
            
            Gauss = True
            print(Heights)
                
            '''#save cross-section of spectrum
            plt.clf()
            plt.plot((np.abs(spectrum[:,int(centerX)])))
            X=np.linspace(centerX-width,centerX+width,width) #creates coordinates
            Y=np.linspace(centerY-height,centerY+height,height)[:,None]
            
            #FIND BEST-FIT GAUSSIAN FOR EXPERIMENTS USING SCIPY
            spectrum = np.where(spectrum==0,np.nan,spectrum)
            spect_gauss = np.zeros((width*height))
            input_coord = np.zeros((2,width*height))
            store_x = []
            store_y = []
            spect_store = []
            for x in range(width):
                for y in range(height):
                    y = int(y)
                    x = int(x)
                    store_x.append(x)
                    store_y.append(y)
                    out = spectrum[y][x]
                    spect_store.append(spectrum[y][x])
            for i in range(width*height):
                input_coord[0][i]=store_x[i]
                input_coord[1][i]=store_y[i]
                spect_gauss[i]=spect_store[i]
            print(input_coord)
            print(input_coord.shape)
            
            guess = [np.max(spectrum), centerX, centerY, 1, 1]
            pred_params, uncert_cov = scipy.optimize.curve_fit(gauss2d, input_coord, spect_gauss, p0=guess)
            print("Output params: amp, centX, centY, sigx, sigy:", pred_params)
            print("guesses: amp, centx, centy: ",guess[0:3])
            break
            
            #FIND BEST-FIT GAUSSIAN USING MODEL
            gmodel = Model(gauss2d, independent_vars = ['x','y'])
            weights = np.where(spectrum==0,0,1)
            print(weights)
            result = gmodel.fit(spectrum,x=X, y=Y, amp = np.max(spectrum), x0=centerX, y0=centerY, sigx =100, sigy = 20)
            print(result.fit_report())
            
            
            plt.plot((gauss2d(X,Y,amp,centerX,centerY,sigx,sigy)[:,int(centerX)]))
            plt.savefig(out_path+"/cross-section_"+ind+".png")
            plt.clf()
            plt.imshow(gauss2d(X,Y,amp,centerX,centerY,sigx,sigy))
            plt.savefig(out_path+"/gaussian.png")'''
            
            print("Creating Bands for %s..."% (ind))
            
            for i in np.arange(NumBands): #looping over all bands
                X=np.linspace(centerX-width,centerX+width,width) #creates coordinates
                Y=np.linspace(centerY-height,centerY+height,height)[:,None]
                if Gauss == True:
                    if i == 0:
                        BandScreen = gauss2d(X,Y,amp,centerX,centerY,sigx,sigy) > Heights[i]
                    else:
                        BandScreen1 = gauss2d(X,Y,amp,centerX,centerY,sigx,sigy)<Heights[i-1]
                        BandScreen2 = gauss2d(X,Y,amp,centerX,centerY,sigx,sigy)>Heights[i]
                        BandScreen = np.where(BandScreen1 & BandScreen2, True,False)
                else:
                    if i==0:
                        #defines the band to be summed over
                        BandScreen = (((X-centerX)/RadiiX[i])**2+((Y-centerY)/RadiiY[i])**2) <=1
                        BandAreas.append(np.pi*RadiiX[i]*RadiiY[i]) #append the area
                    else:
                        #also defines the band and appends the area 
                        BandScreen1 = (((X-centerX)/RadiiX[i-1])**2+((Y-centerY)/RadiiY[i-1])**2) > 1 
                        BandScreen2 = ((X-centerX)/RadiiX[i])**2+((Y-centerY)/RadiiY[i])**2 <=1
                        BandScreen = np.where(BandScreen1 & BandScreen2, True,False)
                        BandAreas.append(np.pi*(RadiiX[i]*RadiiY[i]-RadiiX[i-1]*RadiiY[i-1]))
                
                #displays and saves the masks for inspection. this will overwrite
                #the granularity band power graph
                #plt.imshow(BandScreen) 
                #plt.savefig(out_path+"/mask_"+str(i)+"_"+ind+".png")
               
                #saves the band screen
                BandMasks[:,:,i] = BandScreen
                
                #note the commented-out area denominator, this calculates and saves
                #the band energy
                band_energy[i] = (np.sum(BandMasks[:,:,i] * spectrum))#/(BandAreas[i])
                print("Band %d Complete"% (i))
            band_energy = band_energy/sum(band_energy)
            band_energies[ind]=band_energy
        
            #plotting the band energy for each band.
            plt.plot(band_energy)
            plt.xlabel("Granularity Band Index")
            plt.ylabel("Relative power")
            print("Bands computed")
            
            if save: #saves the files if set
                print("Saving reverse FFTs...")
                filtered_images = np.zeros((height, width * (NumBands + 1))) #creates filters
                filtered_images[:, 0:width] = masked_imgs[ind]/255
                for i in np.arange(NumBands):
                    filtered_fft = np.fft.ifftshift(BandMasks[:,:,i] * fft_mods[ind])
                    filtered_image = np.real(np.fft.ifft2(filtered_fft)) #reverse fft
                    offset = (width * (i + 1)) #offsets image
                    filtered_images[:, offset:(offset+width)] = filtered_image + 0.5
                filtered_images_small=filtered_images
                
                #saves pure inverse
                reverse = np.fft.ifftshift(fft_mods[ind])
                reverse = np.real(np.fft.ifft2(reverse))
                cv2.imwrite(out_path+"/Filters/"+ind+"_reverse_image.png",255*reverse/np.max(reverse))
                
                #resizes and adjusts images
                filtered_images_small_u8 = (filtered_images_small * 200)
                filtered_images_small_u8[filtered_images_small_u8 > 255] = 255
                filtered_images_small_u8[filtered_images_small_u8 < 0] = 0
                filtered_images_small_u8 = np.uint8(filtered_images_small_u8)
                cv2.imwrite(out_path+"/Filters/"+ind+"_filtered_images.png",filtered_images_small_u8)
                print("Reverse FFTs Saved")
            
        #adds legend and saves file    
        plt.legend(labels)
        plt.savefig(out_path+"/granularity_bands.png")
        print("Granularity analysis saved")
    
print("DONE")
    
#FIN
