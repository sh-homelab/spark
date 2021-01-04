## Apache Spark Docker image.

#### How to build image?

```bash
   git clone https://github.com/sh-homelab/spark.git
   cd spark
   make build
```

### Remove existing container 

```bash
   make clean
```

### Build container with custom UUID:GUID.

By default container build as non-root container with UUID:GUID of build user.
To build image with custom UUID:GUID you should pass SPARK_UID


```bash
   export SPARK_UID=99999
   make build
```

> *Keep in mind! By setting SPARK_UID means both UUID and GUID were identical.*
