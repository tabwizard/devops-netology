{
  components: {

    "mytestapp": {
      "replicas": 1,
      "name": "backend",
      "image": "nginx:latest",
      "ports": {
        "containerPortName": "http",
        "containerPort": 80,
        "containerPortProtocol": "TCP"
      },
      "service": {
        "port": 80
      }
    },
  }
}
