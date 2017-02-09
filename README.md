# docker-build-aws-example

This repo shows how to safely pass AWS CLI credentials into the Docker build process. You might need to do this, for instance, if your Dockerfile needs to pull a private file from S3 and place it in the Docker image being built.

## Warning!

Passing *standard* AWS credentials using Docker build arguments is *not* safe. The reason is that the value of Docker build arguments are easily discoverable using the [docker history](https://docs.docker.com/engine/reference/commandline/history/) command. E.g.:

```
$ docker history d8dfd80d0317
MAGE               CREATED             CREATED BY                                      SIZE                COMMENT
d8dfd80d0317        3 hours ago         /bin/sh -c #(nop)  CMD ["/bin/sh"]              0 B                 
c1aecd4dc9a1        3 hours ago         |2 AWS_ACCESS_KEY_ID=AKIAINEBSIHH67D3DB5A ...   0 B                 
f516011b96b5        3 hours ago         |2 AWS_ACCESS_KEY_ID=AKIAINEBSIHH67D3DB5A ...   89 MB               
99087984b4ac        3 hours ago         /bin/sh -c #(nop)  ARG AWS_SECRET_ACCESS_KEY    0 B                 
483e7b57cef7        3 hours ago         /bin/sh -c #(nop)  ARG AWS_ACCESS_KEY_ID        0 B                 
0328fc679884        3 hours ago         /bin/sh -c #(nop)  MAINTAINER Cornell IT C...   0 B                 
88e169ea8f46        6 weeks ago         /bin/sh -c #(nop) ADD file:92ab746eb22dd3e...   3.98 MB
```

The entire build argument values for the image can be shown with `docker history --no-trunc d8dfd80d0317`.

## A Safer Way

Instead of passing standard AWS credentials as build arguments, it is much safer to use [temporary AWS credentials](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp.html). When temporary credentials are passed as Docker build arguments, they will become useless when they expire, always within 60 minutes.

Fortunately, at Cornell, there is an easy solution to obtain temporary AWS access key credentials. That is by using the Cornell Shibboleth SSO already configured for most AWS accounts at Cornell. See [Using Shibboleth for AWS API and CLI access](https://blogs.cornell.edu/cloudification/2016/07/05/using-shibboleth-for-aws-api-and-cli-access/) for the process. After following those directions, you will have temporary credentials stored in `~/.aws/credentials` under the `[saml]` profile. (Note that the current incarnation of that tool uses the default lifetime of the temporary credentials which is 60 minutes.)

The [export-saml-creds.sh](export-saml-creds.sh) script in this repo parses your `~/.aws/credentials` file and outputs `export` commands to be `eval`ed in your shell to setup AWS credentials environment variables.

## Running this Example

This [Dockerfile](Dockerfile) in this repo simply uses the AWS CLI to list the buckets in your AWS account during the Docker build. That RUN command is a stand-in for any AWS CLI command that requires AWS credentials.

1. Clone this repo.

  ```
  $ git clone https://github.com/CU-CloudCollab/docker-build-aws-example.git
  

1. Setup environment variables so that they can be passed into the build.

  ```
  $ export AWS_ACCESS_KEY_ID=<your_IAM_user_credentials_access_key>
  $ export AWS_SECRET_ACCESS_KEY=<your_IAM_user_credentials_secret_key>
  ```

1. Build the image, passing in build arguments.

  ```
  $ docker build --build-arg AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID --build-arg AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY --rm --no-cache .
  Sending build context to Docker daemon  34.3 kB
  Step 1/7 : FROM alpine:3.5
   ---> 88e169ea8f46
  Step 2/7 : MAINTAINER Cornell IT Cloud DevOps Team <cloud-devops@cornell.edu>
   ---> Running in 25edb3a2915a
   ---> 0328fc679884
  Removing intermediate container 25edb3a2915a
  Step 3/7 : ARG AWS_ACCESS_KEY_ID
   ---> Running in 494bf4ed9394
   ---> 483e7b57cef7
  Removing intermediate container 494bf4ed9394
  Step 4/7 : ARG AWS_SECRET_ACCESS_KEY
   ---> Running in 507cff61a43b
   ---> 99087984b4ac
  Removing intermediate container 507cff61a43b
  Step 5/7 : RUN wget "s3.amazonaws.com/aws-cli/awscli-bundle.zip" -O "awscli-bundle.zip" &&   unzip awscli-bundle.zip &&   apk add --update python &&   rm /var/cache/apk/* &&   ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws &&   rm awscli-bundle.zip &&   rm -rf awscli-bundle
   ---> Running in 3e1efcb56200
  Connecting to s3.amazonaws.com (54.231.49.83:80)
  awscli-bundle.zip     30% |*********                      |  2531k  0:00:02 ETA
  awscli-bundle.zip    100% |*******************************|  8317k  0:00:00 ETA

  Archive:  awscli-bundle.zip
    inflating: awscli-bundle/install
    inflating: awscli-bundle/packages/six-1.10.0.tar.gz
    inflating: awscli-bundle/packages/awscli-1.11.45.tar.gz
    inflating: awscli-bundle/packages/PyYAML-3.12.tar.gz
    inflating: awscli-bundle/packages/colorama-0.3.7.zip
    inflating: awscli-bundle/packages/python-dateutil-2.6.0.tar.gz
    inflating: awscli-bundle/packages/s3transfer-0.1.10.tar.gz
    inflating: awscli-bundle/packages/argparse-1.2.1.tar.gz
    inflating: awscli-bundle/packages/pyasn1-0.2.2.tar.gz
    inflating: awscli-bundle/packages/simplejson-3.3.0.tar.gz
    inflating: awscli-bundle/packages/rsa-3.4.2.tar.gz
    inflating: awscli-bundle/packages/botocore-1.5.8.tar.gz
    inflating: awscli-bundle/packages/jmespath-0.9.1.tar.gz
    inflating: awscli-bundle/packages/ordereddict-1.1.tar.gz
    inflating: awscli-bundle/packages/futures-3.0.5.tar.gz
    inflating: awscli-bundle/packages/docutils-0.13.1.tar.gz
    inflating: awscli-bundle/packages/virtualenv-15.1.0.tar.gz
    fetch http://dl-cdn.alpinelinux.org/alpine/v3.5/main/x86_64/APKINDEX.tar.gz
    fetch http://dl-cdn.alpinelinux.org/alpine/v3.5/community/x86_64/APKINDEX.tar.gz
    (1/10) Installing libbz2 (1.0.6-r5)
    (2/10) Installing expat (2.2.0-r0)
    (3/10) Installing libffi (3.2.1-r2)
    (4/10) Installing gdbm (1.12-r0)
    (5/10) Installing ncurses-terminfo-base (6.0-r7)
    (6/10) Installing ncurses-terminfo (6.0-r7)
    (7/10) Installing ncurses-libs (6.0-r7)
    (8/10) Installing readline (6.3.008-r4)
    (9/10) Installing sqlite-libs (3.15.2-r0)
    (10/10) Installing python2 (2.7.13-r0)
  Executing busybox-1.25.1-r0.trigger
  OK: 51 MiB in 21 packages
  Running cmd: /usr/bin/python virtualenv.py --python /usr/bin/python /usr/local/aws
  Running cmd: /usr/local/aws/bin/pip install --no-index --find-links file:///awscli-bundle/packages awscli-1.11.45.tar.gz
  You can now run: /usr/local/bin/aws --version
   ---> f516011b96b5
  Removing intermediate container 3e1efcb56200
  Step 6/7 : RUN aws s3 ls
   ---> Running in 1e7130603335
  2016-09-01 19:45:11 my-sample-bucket-1
  2016-07-12 16:15:47 my-sample-bucket-2
   ---> c1aecd4dc9a1
  Removing intermediate container 1e7130603335
  Step 7/7 : CMD /bin/sh
   ---> Running in 62d49b11aaf9
   ---> d8dfd80d0317
  Removing intermediate container 62d49b11aaf9
  Successfully built d8dfd80d0317
  ```

  Pay attention to step 6 of the build output above. That is where the AWS CLI is invoked, and in this example it shows the output from that as:

  ```
  2016-09-01 19:45:11 my-sample-bucket-1
  2016-07-12 16:15:47 my-sample-bucket-2
  ```

  If you hadn't passed in the AWS credentials as build arguments, you would have seen a message in the build output like:

  ```
  Unable to locate credentials. You can configure credentials by running "aws configure".
  The command '/bin/sh -c aws s3 ls' returned a non-zero code: 255
  ```

  In that case, the build failed because it could not execute the RUN command successfully.


## Notes

This example uses [official Docker Alpine images](https://hub.docker.com/_/alpine/) as the base image simply to make the build process faster. The same approach can be used with any other Docker base image.