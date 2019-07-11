import pathlib
from colorama import Fore
from python_terraform import *
from iac_manager import IACManager
from manifest import *

env = input("Environment: ") or "example"

with open('{0}/manifests/{1}.yaml'.format(pathlib.Path(__file__).parent, env), 'r') as stream:

    try:

        ##################### Manifest parsing #####################
        manifest = Manifest(yaml.safe_load(stream))
        print(Fore.BLUE + 'Destroy manifest with name: ' + manifest.name)

        ##################### Terraform #####################
        iac = IACManager('%s/terraform' % pathlib.Path(__file__).parent)
        code, _, _ = iac.tf.destroy(
            var=manifest.tf_vars(),
            capture_output=False,
            no_color=IsNotFlagged)

        if code != 0:
            raise Exception('error in Terraform destroy gitlab')

    except yaml.YAMLError as exc:
        print(Fore.RED, exc)
    except subprocess.CalledProcessError as exc:
        print(Fore.RED, exc)
    except Exception as inst:
        print(Fore.RED, inst)
