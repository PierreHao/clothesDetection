# Fashion AI: Fast Region-based Convolutional Networks for object detection

Created by Tingwu Wang, since the internship in SenseTime and CUHK.

## Introduction

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

### generating the proposals

Before testing the dataset, we need to generate the proposals.

The c++ code for generating the proposals is located at the `$FashionAI/rcnn_test/test`. And you should modify the code for specific purpose, as most of the codes have been written for specific ones. The `CCPCFD_proposals.cpp` is written to process a image directory in the following style.

```shell
cd $FashionAI/rcnn_test
./bin/CCPCFD_proposals.bin $INPUT_IMAGE_DIR
```

Then a proposals directory will be generating at the same directory tree

```c++
if (argc <= 1) printf("Error, must have the root path\n");
string ROOT_DIR = string(argv[1]);
string IMAGE_DIR = ROOT_DIR;
string PPS_DIR = ROOT_DIR + "/.." + "/proposals";
```

### Testing the datasets

After generating the datasets (which is already finished in all the datasets), you could continue with the testing.

A basic example of testing the dataset looks like this

```shell
$FashionAI/tools/generate_test.py --gpu 1 
--model $FashionAI/output/default/clothesDataset_train_3CL=True_MUL_LAB=True_SOFTMAX=True_FG_THRESH=0.5ATTR_REVISE=False_SEP_DETECTOR=1/caffenet_fast_rcnn_iter_40000.caffemodel 
--prototxt $FashionAImodels/ClothCaffeNet_binDetector/test_bin_softmax_multilabel.prototxt --testset Jingdong
```

you could change the `--model` and the `--prototxt` according to your own need. 
But the other arguments are tricky, and modification of the code is needed.

The `--testset` arguments take the input datasets as arguments. 
Currently the `Jingdong` and `forever21` (It's actually the CCP dataset when I say forever21, I got mistaken about the name of the dataset) are supported.
And a special `general` dataset is implemented too as described below.

#### The Jingdong Dataset

The `Jingdong` dataset are read and the results are saved like

```python
Jingdong_root_dir = '/media/DataDisk/twwang/fast-rcnn/data/clothesDataset/test'
Jingdong_output_dir = '/media/DataDisk/twwang/fast-rcnn/data/results/Jingdong'
```

If you are testing a new model and do not want to **overwrite** the old results, you will need to change the `Jingdong_output_dir`.
For example, a new output directory could be like `$FashionAI/data/results/$NEW_Jingdong_DIR`. 
And make sure to add subdirectories for saving the image demos, i.e., the images with the detected boxes ploted on it. 

```shell
cd $FashionAI/data/results/$NEW_Jingdong_DIR
mkdir images
for ((i=1;i<=26;i++))
do
mkdir $i
done
```

The output is saved to `${category_name}floatResults` and `${category_name}intResults` for detection confidence, positions of the box and detected type etc.
When the multi attributive flag is set on, the output will also recorded the multi attributive label results.
The format of the output results are all illustated in the comments in the codes.
**Note** that the `forever21` `Jingdong` results are saved differently.

#### The forever21 dataset

The `forever21` is similar. But the directory tree is different,
as the CCP dataset is small and images are put in the same directory (not like Jingdong one with 26 separate dirs).

```shell
cd $FashionAI/data/results/$NEW_CCP_DIR
mkdir images
```

#### The general dataset

In this case, you simply set the `--testset` to a directory containing the images. The proposals are generated on-the-fly, and will not be saved.
It is convenient, but more time-consuming.

## Data

There are many models and datasets available currently in the projects.

### the finished Model

In the `$FashionAI/output/default/` there are many available trained models.
1. invalid_1fc_multilabel_lose_clothesDataset_train_3CL=True_MUL_LAB=True_FG_THRESH=0.5_23_class:
	Run with `multi_ClothCaffeNet/train_1fc_pool5_multilabel.prototxt`
2. valid_clothesDataset_3CL=True_BLC=True_COF=True_TT1000=True:
	Run with `ClothCaffeNet/train.prototxt`
3. valid_clothesDataset_train_3CL=True_MUL_LAB=True_SOFTMAX=True_FG_THRESH=0.5
	Run with `ClothCaffeNet/train_3_softmax_multilabel`
4. valid_clothesDataset_3CL=True_MUL_LAB=True_SOFTMAX=False_FG_THRESH=0.5
	Run with `multi_ClothCaffeNet/train_1fc_pool5_multilabel.prototxt`. It fixes the 23 class bug
5. valid_bg_bug_removed_clothesDataset_train_3CL=True_MUL_LAB=True_SOFTMAX=False_FG_THRESH=0.5
	Run with `multi_ClothCaffeNet/train_1fc_pool5_multilabel` It fixes the 23 class bug, and the bg attributive bug.
6. valid.5_clothesDataset_3CL=True_MUL_LAB=True_SOFTMAX=False_FG_THRESH=0.5ATTR_REVISE=True
	Run with `multi_ClothCaffeNet/train_1fc_pool5_multilabel.prototxt`. It uses a better way to choose the bg.
7. valid.6_clothesDataset_3CL=True_MUL_LAB=True_SOFTMAX=True_FG_THRESH=0.5ATTR_REVISE=True
	Run with `multi_ClothCaffeNet/train_3_softmax_multilabel.prototxt`. It uses a better way to choose the bg.
8. clothesDataset_3CL=True_BLC=True_COF=True_TT1000=True
	Run with `ClothCaffeNet/train.prototxt`. It is the most stable version 1 model.
  		

### the dataset data

## Misc
