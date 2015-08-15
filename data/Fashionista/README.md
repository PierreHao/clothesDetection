Fashonista benchmark dataset
============================

## Contents

    fashionista_v0.2.1.mat  Training and testing samples with predictions
                            from [Yamaguchi 2012] and [Yamaguchi 2013].
    lib/                    Optional helper utilities.
    startup.m               Optional startup helper.

## Data format

Data samples are stored in `fashionista_v0.2.1.mat`. This mat file contains
both the groundtruth annotations and the parsing results. The exact contents
of the file is the following.

    truths       Struct array of ground truth samples.
    predictions  Struct array of predictions based on [Yamaguchi 2012].
    predictions_paperdoll Struct array of predictions based on [Yamaguchi 2013].
    test_index   Index of testing samples.

To get the corresponding groundtruth annotation for each prediction sample,
use `truths(test_index)`.

The `truths` and `predictions` struct has the following fields.

    index       Index of the sample.
    image       JPEG-encoded image data.
    pose        Struct of pose annotation in PARSE box format [Yang 11].
    annotation  Struct of superpixel annotation.
    id          Internal use.

Use the attached `imdecode(im, 'jpg')` utility to decode image data, or simply
write them out as a binary file.

The superpixel struct has the following fields.

    superpixel_map     PNG-encoded index of superpixel membership.
    superpixel_labels  N-by-1 numeric index of class labels.
    labels             M-by-1 cell string of class names.
    marginals          N-by-M double array of marginal probabilities. Empty for
                       groundtruth annotations.

Use the attached `imdecode(im, 'png')` utility to decode the map data. To get
the labeling of each pixel, use `superpixel_labels(decoded_superpixel_map)`.
Names of the superpixel labels are `labels(superpixel_labels)`. The marginal
probabilities are ordered by the `labels` of the sample. The labels are the
same for all samples.

The pose struct has the following fields.

    point    14-by-2 row vectors [x,y] of the body joints.
    score    Score of the pose estimation. Not used.
    x1       1-by-14 vector of left x coordinates of part bounding box.
    y1       1-by-14 vector of top y coordinates of part bounding box.
    x2       1-by-14 vector of right x coordinates of part bounding box.
    y2       1-by-14 vector of bottom y coordinates of part bounding box.

This is the order of pose annotation.

    {...
        'right_ankle',...
        'right_knee',...
        'right_hip',...
        'left_hip',...
        'left_knee',...
        'left_ankle',...
        'right_hand',...
        'right_elbow',...
        'right_shoulder',...
        'left_shoulder',...
        'left_elbow',...
        'left_hand',...
        'neck',...
        'head'...
    }

The `predictions_paperdoll` struct has the following fields.

    index       Index of the sample.
    image       JPEG-encoded image data.
    pose        Struct of pose estimation in raw format [Yang 11].
    labels      Cell array of 56 category labels.
    labeling    PNG-encoded parsing results.
    id          Internal use.

To get the parse map, use `imdecode(labeling, 'png')`. Pose can be converted to the point format with the `box2point` function.

## Notes

 * v0.2.1 Added Paper Doll parsing.
 * v0.2 Changed to 56-way parsing; Added parsing for training samples;
 * v0.1 Initial data;

Kota Yamaguchi <kyamagu@cs.stonybrook.edu>
