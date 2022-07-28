# Where is the matlab license file? Needed to run Matlab so we can compile
LIC=/Users/rogersbp/Dropbox/containers/mcrsing-docker/license.lic

# MAC address of the compiler container
MAC=02:42:ac:11:00:02

# Will need to set imagemagick perms if using it:
# sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml

xhost + 127.0.0.1

docker run --rm --interactive --tty --privileged \
    --mount type=bind,src=`pwd -P`,dst=/wkdir \
    --mount type=bind,src=${LIC},dst=/usr/local/MATLAB/R2019b/licenses/license.lic \
    --mount type=bind,src=`pwd -P`/INPUTS,dst=/INPUTS \
    --mount type=bind,src=`pwd -P`/OUTPUTS,dst=/OUTPUTS \
    -e DISPLAY=host.docker.internal:0 \
	--mac-address "${MAC}" \
    mcrsing_0242ac110002:singup \
    bash 

xhost - 127.0.0.1
