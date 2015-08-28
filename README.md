# Fashion AI: Fast Region-based Convolutional Networks for object detection

Created by Tingwu Wang, since the internship in SenseTime and CUHK.

### Introduction

It is a framework for clothes detection and attribute retrieving.

# How to use it

**Note:**: In the $FashionAI/lib/fast-rcnn/config.py

## Train the network

In the existing work, several kinds of training is finished.

1. The training of **three class** detector.

It is most basic model.

Make sure the following parameters in the $FashionAI/lib/fast-rcnn/config.py,
the following configurations are set as:

```Python
__C.BG_CHOICE = True
__C.ThreeClass = True

__C.MULTI_LABEL = False
__C.MULTI_LABEL_SOFTMAX = False
 
__C.ATTR_CHOICE = False
__C.SEP_DETECTOR = False
__C.SEP_DETECTOR_NUM = 1
__C.BALANCED = False
__C.DEBUG_CLASS_WHOLE = False
__C.TESTTYPE1000 = False
__C.HDF5_BYPASS_SYS_IM_ROIS = False
__C.HDF5_TEST = False

```

## Test the network

## Data

### the finished Model

### the dataset data
