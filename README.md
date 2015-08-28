# Fashion AI: Fast Region-based Convolutional Networks for object detection

Created by Tingwu Wang, since the internship in SenseTime and CUHK.

### Introduction

It is a framework for clothes detection and attribute retrieving.

## How to use it

**Note:**: In the $FashionAI/lib/fast-rcnn/config.py

The function of the configurations are self-explained. And you could modify them by yourself if you want.
But note that some configurations could not co-exist, e.g., the `__C.SEP_DETECTOR` and the `__C.ThreeClass`.

And some configurations are not supported in certain senarios,
 e.g., the `__C.MULTI_LABEL` is not supported if you are using the training prototxt that only trains the clothes type.

In a word, the config.py must correspond with the prototxt. Otherwise errors will occur.

## Train the network

In the existing work, several kinds of training is finished.

### The training of **three class** detector.

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

__C.BALANCED = False
__C.DEBUG_CLASS_WHOLE = False
__C.TESTTYPE1000 = False
__C.HDF5_BYPASS_SYS_IM_ROIS = False
__C.HDF5_TEST = False
```

Due to the limitation of the labeling of the JD datasets, you could set
 
```python
__C.BG_CHOICE = True
__C.VALID_THRESH = 0.6
```

In this case, we avoid choosing wrong backgrounds, e.g., a proposal that covers the pants is actually a positive example, 
but is wrongly regarded as negative because it it a cloth image and the pant is not labeled.

Then we run the train_net.py under the $FashionAI/tools/ like this:

```shell
python ./tools/train_net.py --gpu 1 --solver /media/DataDisk/twwang/fast-rcnn/models/ClothCaffeNet/solver.prototxt \
--imdb clothesDataset_train --weight /media/DataDisk/twwang/fast-rcnn/data/fast_rcnn_models/CaffeNet.v2.caffemodel
```

In the above arguments, the `--imdb clothesDataset_train` means that we are training on the `clothesDataset`. 
And the `_train` suffix is simply of historical reasons.

Other available datasets are the CFD, Fashionista, CCP dataset. The available datasets are recorded at the $FashionAI/data/DB_info.

### The training of **multi_attributive** detector.

In this part, the detecting of sleeve, neckband and texture attributives is added.
The major part of the training is similar. 

Make sure the following parameters in the $FashionAI/lib/fast-rcnn/config.py,
the following configurations are set as:

```Python
__C.BG_CHOICE = True
__C.ThreeClass = True

__C.MULTI_LABEL = True
__C.MULTI_LABEL_SOFTMAX = False
 
__C.ATTR_CHOICE = False
__C.SEP_DETECTOR = False

__C.BALANCED = False
__C.DEBUG_CLASS_WHOLE = False
__C.TESTTYPE1000 = False
__C.HDF5_BYPASS_SYS_IM_ROIS = False
__C.HDF5_TEST = False
```

Then we modify the `$FashionAI/model/multi_ClothCaffeNet/train_1fc_pool5_multilabel/solver.prototxt` to use the train_1fc_pool5_multilabel.prototxt at the same directory.

We starts the training by :

```shell
python ./tools/train_net.py --gpu 1 --solver /media/DataDisk/twwang/fast-rcnn/models/multi_ClothCaffeNet/solver.prototxt \
--imdb clothesDataset_train --weight /media/DataDisk/twwang/fast-rcnn/data/fast_rcnn_models/CaffeNet.v2.caffemodel
```

Further more, you could modify the config.py

```python
__C.ATTR_CHOICE = True
__C.ATTR_THRESH = 0.3
```

In this case, the proposals will only be determined as positive example for the attributive if it has overlaps percentage of the attribute foreground more than `0.3`.
  
**Note**: Only the JD dataset is labeled with its attributive. The CFD, CCP, Fashionista do not support multi attributive labels.

### The training of **multi_attributive_softmax** detector.

It is basicly the same with the second one, only different in that it uses a different network.

Modify the

```Python
__C.MULTI_LABEL_SOFTMAX = True
```

and trains the network by modifying the `$FashionAI/model/multi_ClothCaffeNet/train_1fc_pool5_multilabel/solver.prototxt` to use the test_3_softmax_multilabel.prototxt at the same directory.

### Training by using the hdf5

This function might have some problem in the CFD, CCP, and Fashionista part.
The idea is very simple, we use the **get_training_roidb_hdf5.py** to generate the hdf5 dataset.

It is simply a change from the Ross' original python port to the caffe port. 
Reading the prototxt in the `$FashionAI/model/hdf5_ClothCaffeNet/train_1fc_pool5_multilabel/solver.prototxt`,
and you will find it quite easy to understand what is going on.

## Test the network

It is worthing noting that the config.py should be the same for the training and the testing. 
And for the record, the testing scale and the training scale configuration in the config.py should always insist the same (600 for test, then 600 for train or 350, 350 for example).

**Note**: Testing is basicly mirroring the operation done in the training part.
We change the prototxt, switching to the corresponding computed model and make sure the config.py is the same in the testing and the training.

### testing the a dataset

Before testing the dataset, we need to generate the proposals.

## Data

### the finished Model

### the dataset data
