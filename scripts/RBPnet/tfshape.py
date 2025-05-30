import tensorflow as tf
import numpy as np

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

for record in parsed_dataset.take(1):
    seq_raw = tf.io.decode_raw(record['sequence'], tf.uint8).numpy()
    prof_raw = tf.io.decode_raw(record['PRPF8_siControl_profile'], tf.float32).numpy()
    
    print("Decoded sequence shape:", seq_raw.shape)
    print("Decoded profile shape:", prof_raw.shape)
    print("Decoded profile (first 10):", prof_raw[:10])
