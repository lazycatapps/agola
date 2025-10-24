{
  runs: [
    {
      name: 'ogola test run',
      tasks: [
        {
          name: 'build and test',
          runtime: {
            type: 'pod',
            arch: 'amd64',
            containers: [
              {
                image: 'alpine:latest',
              },
            ],
          },
          steps: [
            {
              type: 'run',
              name: 'print hello',
              command: 'echo "Hello from Agola!"',
            },
            {
              type: 'run',
              name: 'show system info',
              command: 'uname -a && cat /etc/os-release',
            },
            {
              type: 'run',
              name: 'list files',
              command: 'ls -la',
            },
          ],
        },
      ],
    },
  ],
}

