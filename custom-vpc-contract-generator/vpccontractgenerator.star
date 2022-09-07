#   Copyright IBM Corporation 2021
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# Creates IBM VPC contract file
def transform(new_artifacts, old_artifacts):
    pathMappings = []
    artifacts = []
    usesVPC = m2k.query({"id": "move2kube.ibmvpc", "type": "Select", "description": "Do you use IBM VPC?", "hints": ["A VPC contract file will be created."], "options": ["Yes", "No"]})
    if usesVPC == "No":
        return {'pathMappings': pathMappings, 'artifacts': artifacts}

    confTypes = m2k.query({"id": "move2kube.ibmvpc.types", "type": "MultiSelect", "description": "What are the types?", "options": ["workload", "env"]})

    if len(confTypes) == 0:
        return {'pathMappings': pathMappings, 'artifacts': artifacts}

    data = {}

    for confType in confTypes:
        if confType == "env":
            logHostName = m2k.query({"id": "move2kube.ibmvpc.env.loghostname", "type": "Input", "description": "What is the log DNA hostname?", "default": ""})
            ingestionKey = m2k.query({"id": "move2kube.ibmvpc.env.ingestionkey", "type": "Input", "description": "What is the ingestion key?", "default": ""})
            logPortStr = m2k.query({"id": "move2kube.ibmvpc.env.logport", "type": "Input", "description": "What is the log port?", "default": "8080"})
            volumeCountStr = m2k.query({"id": "move2kube.ibmvpc.env.volumecount", "type": "Input", "description": "How many volumes?", "default": "0"})
            volumeCount = int(volumeCountStr)
            volumes = {}

            for i in range(volumeCount):
                volumeName = m2k.query({"id": "move2kube.ibmvpc.env.volumes[%d].name" % (i), "type": "Input", "description": "What is volume name?", "default": ""})
                volumeSeed = m2k.query({"id": "move2kube.ibmvpc.env.volumes[%d].seed" % (i), "type": "Input", "description": "What is volume seed?", "default": ""})
                volumeMount = m2k.query({"id": "move2kube.ibmvpc.env.volumes[%d].mount" % (i), "type": "Input", "description": "What is volume mount?", "default": ""})
                volumeFS = m2k.query({"id": "move2kube.ibmvpc.env.volumes[%d].fs" % (i), "type": "Input", "description": "What is volume filesystem?", "default": ""})
                volume = {"mount": volumeMount, "seed": volumeSeed, "filesystem": volumeFS}
                volumes[volumeName] = volume
            data["EnvType"] = confType
            data["LogHostName"] = logHostName
            data["IngestionKey"] = ingestionKey
            data["LogPort"] = logPortStr
            data["EnvVolumes"] = volumes

        elif confType == "workload":
            authsCountStr = m2k.query({"id": "move2kube.ibmvpc.workload.authscount", "type": "Input", "description": "How many services?", "default": "0"})
            authsCount = int(authsCountStr)
            auths = {}
            for i in range(authsCount):
                serviceAdress = m2k.query({"id": "move2kube.ibmvpc.workload.service[%d].address" % (i), "type": "Input", "description": "What is service address?", "default": ""})
                serviceUserName = m2k.query({"id": "move2kube.ibmvpc.env.service[%d].username" % (i), "type": "Input", "description": "What is username?", "default": ""})
                servicePass = m2k.query({"id": "move2kube.ibmvpc.env.service[%d].pass" % (i), "type": "Input", "description": "What is password?", "default": ""})
                auth = {"username": serviceUserName, "password": servicePass}
                auths[serviceAdress] = auth
                composeArchive = m2k.query({"id": "move2kube.ibmvpc.workload.compose.archive", "type": "Input", "description": "What is the compose archive?", "default": ""})
                imagesCountStr = m2k.query({"id": "move2kube.ibmvpc.workload.imagescount", "type": "Input", "description": "How many images?", "default": "0"})
                imagesCount = int(imagesCountStr)
                images = {}

            for i in range(imagesCount):
                registryAdress = m2k.query({"id": "move2kube.ibmvpc.workload.registry[%d].address" % (i), "type": "Input", "description": "What is registry address?", "default": ""})
                registryNotary = m2k.query({"id": "move2kube.ibmvpc.env.registry[%d].notary" % (i), "type": "Input", "description": "What is notary?", "default": ""})
                registryPublicKey = m2k.query({"id": "move2kube.ibmvpc.env.registry[%d].publickey" % (i), "type": "Input", "description": "What is publickey?", "default": ""})
                image = {"notary": registryNotary, "publicKey": registryPublicKey}
                images[registryAdress] = image

            workloadVolumeCountStr = m2k.query({"id": "move2kube.ibmvpc.workload.volumecount", "type": "Input", "description": "How many volumes for workload?", "default": "0"})
            workloadVolumeCount = int(workloadVolumeCountStr)
            
            workloadVolumes = {}

            for i in range(workloadVolumeCount):
                volumeName = m2k.query({"id": "move2kube.ibmvpc.workload.volumes[%d].name" % (i), "type": "Input", "description": "What is volume name?", "default": ""})
                volumeSeed = m2k.query({"id": "move2kube.ibmvpc.workload.volumes[%d].seed" % (i), "type": "Input", "description": "What is volume seed?", "default": ""})
                volumeMount = m2k.query({"id": "move2kube.ibmvpc.workload.volumes[%d].mount" % (i), "type": "Input", "description": "What is volume mount?", "default": ""})
                volumeFS = m2k.query({"id": "move2kube.ibmvpc.workload.volumes[%d].fs" % (i), "type": "Input", "description": "What is volume filesystem?", "default": ""})
                volume = {"mount": volumeMount, "seed": volumeSeed, "filesystem": volumeFS}
                workloadVolumes[volumeName] = volume

            workloadEnvsCountStr = m2k.query({"id": "move2kube.ibmvpc.workload.envcount", "type": "Input", "description": "How many envs?", "default": "0"})
            workloadEnvsCount = int(workloadEnvsCountStr)

            workloadEnvs = {}

            for i in range(workloadEnvsCount):
                envKey = m2k.query({"id": "move2kube.ibmvpc.workload.envs[%d].key" % (i), "type": "Input", "description": "What is env key?", "default": ""})
                envValue = m2k.query({"id": "move2kube.ibmvpc.workload.envs[%d].value" % (i), "type": "Input", "description": "What is env value?", "default": ""})
                workloadEnvs[envKey] = envValue

            data["WorkloadType"] = confType
            data["Auths"] = auths
            data["ComposeArchive"] = composeArchive
            data["Images"] = images
            data["WorkloadVolumes"] = workloadVolumes
            data["WorkloadEnvs"] = workloadEnvs
    pathMappings.append({'type': 'Template', 'sourcePath': 'customizations/custom-vpc-contract-generator/templates/', 'templateConfig': data})
    return {'pathMappings': pathMappings, 'artifacts': artifacts}

# TODO
# encryption
# documentation
