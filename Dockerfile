FROM "ubuntu"

RUN apt-get update && yes | apt-get upgrade
RUN mkdir -p /root/Project/tensorflow/models
RUN apt-get install -y git python-pip
RUN pip install pip -U
RUN pip install tensorflow
RUN apt-get install -y protobuf-compiler python-pil python-lxml
RUN pip install jupyter
RUN pip install jupyterlab
RUN pip install matplotlib

# for tensorflow object detection
RUN git clone https://github.com/tensorflow/models.git /root/Project/tensorflow/models
WORKDIR /root/Project/tensorflow/models/research
RUN protoc object_detection/protos/*.proto --python_out=.
RUN export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

# for jupyter notebook, password: root 
RUN jupyter notebook --generate-config --allow-root
RUN echo "c.NotebookApp.password = u'sha1:6a3f528eec40:6e896b6e4828f525a6e20e5411cd1c8075d68619'" >> /root/.jupyter/jupyter_notebook_config.py

# for eval.py
RUN pip install Cython
RUN pip install "git+https://github.com/philferriere/cocoapi.git#egg=pycocotools&subdirectory=PythonAPI"
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y python-tk

# for jupyterlab
EXPOSE 8888

# for tensorboard
EXPOSE 6006

WORKDIR /root
CMD ["nohup", "jupyter", "lab", "--allow-root", "--notebook-dir=/root", "--ip=''", "--port=8888", "--no-browser"]

