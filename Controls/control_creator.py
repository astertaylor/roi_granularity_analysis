# -*- coding: utf-8 -*-
"""
Created on Tue Jun 30 22:44:05 2020

@author: aster
"""

import cv2
import numpy as np
sizes = [1,2,4,8,16,32,64,128]
print(sizes)
for i in sizes:
    dim = int(128/i)
    ind = sizes.index(i)+1
    filename = "checkerboard_%d.png"% (ind)
    board = np.ones((256,256,3))
    board[:,:,0] = board[:,:,1] = board[:,:,2] = 255*np.kron([[1, 0] * dim, 
                                                [0, 1] * dim] * dim, np.ones((i, i)))
    board[:,:,0] = board[:,:,1] = board[:,:,2] = np.where(board[:,:,0]==0,1,board[:,:,0])
    cv2.imwrite(filename,board)