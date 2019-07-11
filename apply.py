import yaml
import pathlib
import base64
import os
from colorama import Fore
from python_terraform import *
from k8s_manager import K8sManager
from iac_manager import IACManager
from manifest import *

env = input("Environment: ") or "example"

with open('{0}/manifests/{1}.yaml'.format(pathlib.Path(__file__).parent, env), 'r') as stream:

    try:

        ##################### Manifest parsing #####################
        manifest = Manifest(yaml.safe_load(stream))
        print(Fore.BLUE + 'Apply manifest with name: ' + manifest.name)
        gitlab = manifest.gitlab
        cluster = manifest.infrastructure.cluster

        ##################### Terraform #####################
        iac = IACManager('%s/terraform' % pathlib.Path(__file__).parent)
        code, _, _ = iac.tf.apply(
            var=manifest.tf_vars(),
            capture_output=False,
            no_color=IsNotFlagged)

        if code != 0:
            raise Exception('error in Terraform gitlab')

        # get terraform outputs
        storage_sa_key = iac.get_gitlab_storage_service_account_key()
        gitlab_external_address = iac.get_gitlab_external_address()
        db_host = iac.get_gitlab_instance_dns_record_name()
        db_name = iac.get_gitlab_database_name()
        db_username = iac.get_gitlab_user_name()
        db_password = iac.get_gitlab_user_password()
        gitlab_bucket_registry = iac.get_gitlab_bucket_registry()
        gitlab_bucket_lfs = iac.get_gitlab_bucket_lfs()
        gitlab_bucket_artifacts = iac.get_gitlab_bucket_artifacts()
        gitlab_bucket_uploads = iac.get_gitlab_bucket_uploads()
        gitlab_bucket_packages = iac.get_gitlab_bucket_packages()
        gitlab_bucket_externaldiffs = iac.get_gitlab_bucket_externaldiffs()
        gitlab_bucket_pseudonymizer = iac.get_gitlab_bucket_pseudonymizer()
        gitlab_bucket_backup = iac.get_gitlab_bucket_backup()
        gitlab_bucket_backup_tmp = iac.get_gitlab_bucket_backup_tmp()
        storage_sa_email = iac.get_storage_sa_email()

        # Get gcloud credentials for newly created cluster
        print(Fore.BLUE + 'Get gcloud credentials...' + Fore.WHITE)
        subprocess.check_call(['gcloud container clusters get-credentials %s' % cluster.name
                               + ' --zone ' + cluster.zone
                                 + ' --project ' + manifest.gcp_project
                               ], shell=True)

        # K8S manager instance
        k8s = K8sManager()

        # set users cluster admins
        print(Fore.BLUE + 'Set cluster admins...' + Fore.WHITE)
        for u in cluster.admins:
            k8s.apply_cluster_admin_role_binding_to_user(u)
            print(u)

        ##################### Tiller setup #####################
        tiller = 'tiller'
        # create a service account for tiller...
        print(Fore.BLUE + 'Create tiller serviceaccount...' + Fore.WHITE)
        k8s.apply_service_account(tiller, 'kube-system')
        print('done')

        # and set it as cluster-admin
        print(Fore.BLUE + 'Set tiller as cluster_admin...' + Fore.WHITE)
        k8s.apply_cluster_admin_role_binding_to_serviceaccount(
            tiller, 'kube-system')
        print('done')

        # Initialize helm, install tiller
        print(Fore.BLUE + 'Initialize helm / tiller...' + Fore.WHITE)
        subprocess.check_call(
            [
                'helm init'
                + ' --service-account %s' % tiller
                + ' --wait'
                + ' --node-selectors "main"=true'
            ],
            shell=True,
            stdout=sys.stdout
        )

        ##################### Helm repo setup #####################
        # Add charts to helm repo
        print(Fore.BLUE + 'Add charts to helm repo...' + Fore.WHITE)
        subprocess.check_call(
            ['helm repo add gitlab https://charts.gitlab.io/'],
            shell=True,
            stdout=sys.stdout
        )

        # Add charts to helm repo
        print(Fore.BLUE + 'Update helm repo...' + Fore.WHITE)
        subprocess.check_call(
            ['helm repo update'],
            shell=True,
            stdout=sys.stdout
        )

        ##################### gitlab-secrets chart installation #####################

        # gitlab registry secrets
        registry_secret = 'gitlab-registry'
        registry_storage_key = 'storage'
        registry_storage_extraKey = 'gcs.json'

        # gitlab storage secrets
        storage_secret = 'gitlab-storage'
        storage_connection_key = 'connection'

        # gitlab task-runner secrets
        s3cmd_secret = 'gitlab-s3cmd'
        s3cmd_config_key = 'config'
        s3cmd_access_key = gitlab.s3cmd.access_key
        s3cmd_secret_key = gitlab.s3cmd.secret_key

        # database secrets
        db_secret = 'gitlab-postgresql'
        db_password_key = 'password'

        # install gitlab-secrets charts
        print(Fore.BLUE + 'Install gitlab-secrets chart' + Fore.WHITE)
        subprocess.check_call(
            [
                'helm upgrade --install gitlab-secrets ./kubernetes/helm/gitlab-secrets'

                + ' --set nodeSelector."main"=true'

                # gitlab registry secrets
                + ' --set registry.secretName=%s' % registry_secret
                + ' --set registry.storageKey=%s' % registry_storage_key
                + ' --set registry.bucket=%s' % gitlab_bucket_registry
                + ' --set registry.keyFile=%s' % registry_storage_extraKey
                + ' --set registry.storageServiceAccountKey=%s' % storage_sa_key

                # gitlab storage secrets
                + ' --set storage.secretName=%s' % storage_secret
                + ' --set storage.connectionKey=%s' % storage_connection_key
                + ' --set storage.storageServiceAccountKey=%s' % storage_sa_key
                + ' --set storage.googleProject=%s' % manifest.gcp_project
                + ' --set storage.googleClientEmail=%s' % storage_sa_email

                # gitlab task-runner secrets
                + ' --set s3cmd.secretName=%s' % s3cmd_secret
                + ' --set s3cmd.configKey=%s' % s3cmd_config_key
                + ' --set s3cmd.accessKey=%s' % s3cmd_access_key
                + ' --set s3cmd.secretKey=%s' % s3cmd_secret_key

                # database secrets
                + ' --set database.secretName=%s' % db_secret
                + ' --set database.passwordKey=%s' % db_password_key
                + ' --set database.password=%s' % db_password

            ], shell=True)

        ##################### Gitlab chart installation #####################
        print(Fore.BLUE + 'Install gitlab chart version: %s...' %
              gitlab.chart_version + Fore.WHITE)
        subprocess.check_call(
            [
                'helm upgrade --install gitlab gitlab/gitlab'

                + ' --set nodeSelector."main"=true'

                + ' --version %s' % gitlab.chart_version
                + ' --set global.edition=ce'

                + ' --set global.hosts.domain=%s' % gitlab.domain
                + ' --set global.hosts.externalIP=%s' % gitlab_external_address
                + ' --set global.hosts.hostSuffix=%s' % gitlab.host_suffix

                + ' --set certmanager-issuer.email=%s' % gitlab.issuer_email

                # Storing MR diffs on external storage is not enabled by default.
                # So, for the object storage settings for externalDiffs to take effect,
                # global.appConfig.externalDiffs.enabled key should have a true value.
                + ' --set global.appConfig.externalDiffs.enabled=true'

                + ' --set global.minio.enabled=false'
                + ' --set global.registry.enabled=true'

                + ' --set global.registry.bucket=%s' % gitlab_bucket_registry
                + ' --set registry.storage.secret=%s' % registry_secret
                + ' --set registry.storage.key=%s' % registry_storage_key
                + ' --set registry.storage.extraKey=%s' % registry_storage_extraKey

                + ' --set global.appConfig.lfs.bucket=%s' % gitlab_bucket_lfs
                + ' --set global.appConfig.lfs.connection.secret=%s' % storage_secret
                + ' --set global.appConfig.lfs.connection.key=%s' % storage_connection_key

                + ' --set global.appConfig.artifacts.bucket=%s' % gitlab_bucket_artifacts
                + ' --set global.appConfig.artifacts.connection.secret=%s' % storage_secret
                + ' --set global.appConfig.artifacts.connection.key=%s' % storage_connection_key

                + ' --set global.appConfig.uploads.bucket=%s' % gitlab_bucket_uploads
                + ' --set global.appConfig.uploads.connection.secret=%s' % storage_secret
                + ' --set global.appConfig.uploads.connection.key=%s' % storage_connection_key

                + ' --set global.appConfig.packages.bucket=%s' % gitlab_bucket_packages
                + ' --set global.appConfig.packages.connection.secret=%s' % storage_secret
                + ' --set global.appConfig.packages.connection.key=%s' % storage_connection_key

                + ' --set global.appConfig.externalDiffs.enabled=true'
                + ' --set global.appConfig.externalDiffs.bucket=%s' % gitlab_bucket_externaldiffs
                + ' --set global.appConfig.externalDiffs.connection.secret=%s' % storage_secret
                + ' --set global.appConfig.externalDiffs.connection.key=%s' % storage_connection_key

                + ' --set global.appConfig.pseudonymizer.bucket=%s' % gitlab_bucket_pseudonymizer
                + ' --set global.appConfig.pseudonymizer.connection.secret=%s' % storage_secret
                + ' --set global.appConfig.pseudonymizer.connection.key=%s' % storage_connection_key

                + ' --set global.appConfig.backups.bucket=%s' % gitlab_bucket_backup
                + ' --set global.appConfig.backups.tmpBucket=%s' % gitlab_bucket_backup_tmp

                + ' --set gitlab.task-runner.backups.objectStorage.config.secret=%s' % s3cmd_secret
                + ' --set gitlab.task-runner.backups.objectStorage.config.key=%s' % s3cmd_config_key
                + ' --set gitlab.task-runner.persistence.enabled=true'

                + ' --set postgresql.install=false'
                + ' --set global.psql.host=%s' % db_host
                + ' --set global.psql.password.secret=%s' % db_secret
                + ' --set global.psql.password.key=%s' % db_password_key

                + ' --set global.psql.database=%s' % db_name
                + ' --set global.psql.username=%s' % db_username
            ],
            shell=True,
            stdout=sys.stdout
        )

    except yaml.YAMLError as exc:
        print(Fore.RED, exc)
    except subprocess.CalledProcessError as exc:
        print(Fore.RED, exc)
    except Exception as inst:
        print(Fore.RED, inst)
