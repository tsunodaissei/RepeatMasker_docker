FROM ubuntu:18.04

LABEL maintainer=" Issei Tsunoda and e-mail is _____@______"
# I refer https://github.com/jmonlong/docker-repeatmasker

# If you use a proxy server, then you may need a script of something like export https_proxy="http://proxy.domain.name.like.ac.jp:XXXX" before build command of images
# To build this image
#     "docker build  -t my_image .  " #The last period is necessary.
# To make a container of the image,  here we use the current directory of the host OS as a shared folder between the host OS and guest OS, which is named as "home" in the guest OS. In the guest OS, to get back to the home directory, use "cd /home"
#     docker run -it -d -v ${PWD}:/home --workdir /home  --name my_container my_image
# To run the container 
#     docker exec -it my_container /bin/bash    

RUN apt-get update \
        && apt-get install -y --no-install-recommends \
        wget \
        unzip \
        gcc \ 
        tree \ 
        build-essential \
        time \
        python3 \
        curl \
        python3-pip \
        python-setuptools \
        locales \
        make \
        python-dev \
        && rm -rf /var/lib/apt/lists/*

#RUN pip3 install --upgrade pip3

RUN pip3 install h5py

RUN pip3 install awscli

RUN wget http://eddylab.org/software/hmmer/hmmer-3.2.1.tar.gz && \
        tar -xzf hmmer-3.2.1.tar.gz && \
        cd hmmer-3.2.1 && \
        ./configure && \
        make && \
        make install && \
        cd .. && rm -r hmmer-3.2.1 hmmer-3.2.1.tar.gz

WORKDIR /usr/local/bin
RUN wget https://github.com/Benson-Genomics-Lab/TRF/releases/download/v4.09.1/trf409.linux64 && \
        mv trf*.linux64 trf && chmod +x trf

WORKDIR /usr/local
RUN wget https://www.repeatmasker.org/RepeatMasker/RepeatMasker-4.2.2.tar.gz \
    && tar -xzvf RepeatMasker-*.tar.gz \
        && rm -f RepeatMasker-*.tar.gz


# The following two downloads take times 1~2h so I commented out these downloas, so users must download these by hand 20251110. Here "human" only, and for the other species you need further downloads of dfam39_full.XXX.h5.gz files and put it in the directory  /usr/local/RepeatMasker/Libraries/famdb of the guest OS in the similar manner by hand. 

WORKDIR /usr/local/RepeatMasker/Libraries/famdb
RUN wget https://www.dfam.org/releases/Dfam_3.9/families/FamDB/dfam39_full.7.h5.gz \
	&&  gunzip dfam39_full.7.h5.gz 
#	&&  gunzip dfam39_full.7.h5.gz \
#        && rm -f  dfam39_full.7.h5.gz 

WORKDIR /usr/local/RepeatMasker/Libraries
#RUN wget https://www.dfam.org/releases/Dfam_3.1/families/Dfam.hmm.gz \
#         && gunzip Dfam.hmm.gz

RUN wget https://www.dfam.org/releases/Dfam_3.9/families/Dfam-9.hmm.gz \
 && gunzip Dfam-9.hmm.gz  ## & rm -f Dfam-9.hmm.gz


	
# If you add the files in /usr/local/RepeatMasker/Libraries then run the following by hand
WORKDIR /usr/local/RepeatMasker
# The following, by hand i will do
#RUN perl ./configure -trfbin=/usr/local/bin/trf -hmmerbin=`which nhmmscan`

RUN cpan Text::Soundex

ENV PATH=/usr/local/RepeatMasker:$PATH

RUN export PYTHONIOENCODING=utf8

WORKDIR /home

# ADD test.fa /home

# RUN RepeatMasker --species human test.fa

# Before first execution of the RepeatMasker, execute the following on the directory /usr/local/RepeatMasker in the guest OS and input the following four items interactive manner
#  perl ./configure
#  /usr/local/bin/trf
# 3
# Enter (i.e. input is empty)
# 5


# Once, you run the "perl ./configure", then get back to home directory by the code "cd /home" in which you may put your FASTA file and execute the script "RepeatMasker --species human test.fa" for your FASTA file (here it is test.fa)

# If you get the following error, then execute the following code on the terminal of the guest OS to avoid the error. ERROR UnicodeEncodeError: 'ascii' codec can't encode character '\xf3' in position 575: ordinal not in range(128)
# export PYTHONIOENCODING=utf8


