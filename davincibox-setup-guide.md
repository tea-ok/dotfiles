# Davincibox Setup Notes

Brief setup for DaVinci Resolve using davincibox:
<https://github.com/zelikos/davincibox>

## 1. Prerequisites

Install or verify these on the host:

```bash
command -v podman
command -v toolbox
```

Download the Linux installer from Blackmagic (should be a .zip containing this):

```text
DaVinci_Resolve_<version>_Linux.run
```

Your user may need host GPU groups:

```bash
sudo usermod -aG render,video "$USER"
```

Log out and back in after changing groups.

## 2. Create Davincibox

For Intel or AMD GPUs:

```bash
toolbox create -i ghcr.io/zelikos/davincibox-opencl:latest -c davincibox
```

For NVIDIA GPUs:

```bash
toolbox create -i ghcr.io/zelikos/davincibox:latest -c davincibox
```

NVIDIA systems may also need `nvidia-container-toolkit` on the host.

## 3. Install Resolve

From the directory containing the `.run` installer:

```bash
chmod +x ./DaVinci_Resolve_*_Linux.run
./DaVinci_Resolve_*_Linux.run --appimage-extract
toolbox run --container davincibox setup-davinci squashfs-root/AppRun toolbox
```

Update the container packages:

```bash
toolbox run -c davincibox sudo dnf update -y
```

## 4. Fix Silent Launcher Failure

If launching from the app menu does nothing, test from a terminal:

```bash
toolbox run -c davincibox /usr/bin/run-davinci /opt/resolve/bin/resolve
```

If you see an error like this:

```text
/opt/resolve/bin/resolve: symbol lookup error: /opt/resolve/bin/resolve: undefined symbol: _ZNSt3__117bad_function_callD1Ev
```

Install Fedora's libc++ in the container:

```bash
toolbox run -c davincibox sudo dnf install -y libcxx
```

Patch `run-davinci` to preload the correct libc++ path:

```bash
toolbox run -c davincibox sudo sed -i 's|LD_PRELOAD=/usr/lib64/lib/libc++.so.1|LD_PRELOAD=/usr/lib64/libc++.so.1|' /usr/bin/run-davinci
```

Remove any stale invisible Resolve process:

```bash
toolbox run -c davincibox pkill -9 davinci-resolve
```

Test again:

```bash
toolbox run -c davincibox /usr/bin/run-davinci /opt/resolve/bin/resolve
```

## 5. Launcher

The generated desktop entry should be here:

```text
~/.local/share/applications/DaVinciResolve.desktop
```

Its `Exec=` line should look like this:

```ini
Exec=/usr/bin/toolbox run -c davincibox /usr/bin/run-davinci /opt/resolve/bin/resolve %u
```
