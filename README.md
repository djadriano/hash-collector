# hash-collector
Bash script to collect hash commits via txt file and generate a zip of some folder in the repo.
If you need get some folder of repo based on a hash (commit), zip the folder and save, this script will make you happy :)

# How to use:
The script needs the following parameters:
hash commit or file.txt

# Example (txt file):
```sh
$ ./hash-collector.sh file.txt
```

# Example (hash commit):
```sh
$ ./hash-collector.sh 13200e0b1cec3c0150e53ffc8b3231ebc19e8cc3
```

# Txt File:
The script read the txt file line by line, so your txt should follow the structure:

```txt
13200e0b1cec3c0150e53ffc8b3231ebc19e8cc3
3ef1d4ed247d8d5389f5a419eee9a4f9cf51a644
3ef1d4ed247d8d5389f5a419eee9a4f9cf51a527
```

# Demo:
![Alt Text](https://i.imgur.com/aILelLW.gif)

