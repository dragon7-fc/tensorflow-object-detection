FROM "ubuntu"

RUN apt-get update && yes | apt-get upgrade
RUN mkdir -p /root/Project/tensorflow/models
RUN apt-get install -y git python-pip
RUN pip install pip -U

##
## install Tensorflow Object Detection API for Python2
##
RUN pip install tensorflow
RUN apt-get install -y protobuf-compiler python-pil python-lxml 
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y python-tk
RUN pip install Cython
RUN pip install jupyter
RUN pip install matplotlib

RUN git clone https://github.com/tensorflow/models.git /root/Project/tensorflow/models

# COCO API installation
RUN git clone https://github.com/cocodataset/cocoapi.git /root/Project/cocoapi
WORKDIR /root/Project/cocoapi/PythonAPI
RUN make
RUN cp -r pycocotools /root/Project/tensorflow/models/research/

# Protobuf Compilation
WORKDIR /root/Project/tensorflow/models/research
RUN protoc object_detection/protos/*.proto --python_out=.

# Add Libraries to PYTHONPATH
RUN export PYTHONPATH=/root/Project/tensorflow/models/research:/root/Project/tensorflow/models/research/slim:/root/Project/cocoapi/PythonAPI
RUN echo PYTHONPATH=/root/Project/tensorflow/models/research:/root/Project/tensorflow/models/research/slim:/root/Project/cocoapi/PythonAPI >> /root/.bashrc

RUN python /root/Project/tensorflow/models/research/setup.py build
RUN python /root/Project/tensorflow/models/research/setup.py install

##
## install jupyter lab
##
RUN pip install jupyterlab

##
## install python3
## 
RUN apt-get install -y software-properties-common python3-software-properties
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get install python3.6

RUN apt-get install -y python3-pip python3-dev
RUN pip3 install -U pip
RUN pip3 install tensorflow
RUN pip3 install Cython
RUN pip3 install pillow
RUN pip3 install lxml
RUN pip3 install jupyter
RUN pip3 install matplotlib

RUN python3 /root/Project/tensorflow/models/research/setup.py build
RUN python3 /root/Project/tensorflow/models/research/setup.py install

##
## install python3 kernel
##
RUN ipython3 kernelspec install-self

##
## install jupyter lab
##
RUN pip3 install jupyterlab

# for jupyter notebook, password: root 
RUN jupyter notebook --generate-config --allow-root
RUN echo "c.NotebookApp.password = u'sha1:6a3f528eec40:6e896b6e4828f525a6e20e5411cd1c8075d68619'" >> /root/.jupyter/jupyter_notebook_config.py

# for jupyterlab
EXPOSE 8888

# for tensorboard
EXPOSE 6006

WORKDIR /root
CMD ["nohup", "jupyter", "lab", "--allow-root", "--notebook-dir=/root", "--ip=''", "--port=8888", "--no-browser"]

