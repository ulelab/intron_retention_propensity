import tensorflow as tf

raw_dataset = tf.data.TFRecordDataset('train.tfrecord')

for raw_record in raw_dataset.take(1):  # preview the first record
    example = tf.train.Example()
    example.ParseFromString(raw_record.numpy())
    print(example)

import tensorflow as tf

raw_dataset = tf.data.TFRecordDataset("train.tfrecord")

feature_description = {
    'sequence': tf.io.FixedLenFeature([], tf.string),
    'PRPF8_siControl_profile': tf.io.FixedLenFeature([], tf.string),
    'score': tf.io.FixedLenFeature([], tf.float32),
    'name': tf.io.FixedLenFeature([], tf.string),
}

def _parse_function(proto):
    return tf.io.parse_single_example(proto, feature_description)

parsed_dataset = raw_dataset.map(_parse_function)

for parsed_record in parsed_dataset.take(1):
    print(parsed_record)
