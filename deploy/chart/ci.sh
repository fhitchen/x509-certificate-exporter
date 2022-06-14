#! /bin/bash

version="$1"
notes="$2"
containsSecurityUpdates="$3"

if [ "$version" = "" ]; then
	echo "Skipping x509 certificate exporter release because no version parameter was passed to the CI script"
	exit
fi

prerelease="false"
versionComponents=(${version//-/ })

if [ ! -z "${versionComponents[1]}" ]; then
	prerelease="true"
fi

echo "Releasing x509 certificate exporter version: $version (prerelease: $prerelease)"

yq -i ".version = \"$version\"" Chart.yaml
yq -i ".appVersion = \"$version\"" Chart.yaml
yq -i ".annotations[\"artifacthub.io/prerelease\"] = \"$prerelease\"" Chart.yaml
yq -i ".annotations[\"artifacthub.io/containsSecurityUpdates\"] = \"$containsSecurityUpdates\"" Chart.yaml

yq -i ".annotations[\"artifacthub.io/changes\"] = \"\"" Chart.yaml
IFS=$'\n'
for line in $notes; do
	yq -i ".annotations[\"artifacthub.io/changes\"] += \"- $(echo "$line" | sed "s/\\\"/\\\\\"/g")\"" Chart.yaml
	yq -i $'.annotations[\"artifacthub.io/changes\"] += "\n"' Chart.yaml
done
