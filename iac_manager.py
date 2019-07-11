from python_terraform import *
import base64


class IACManager(object):

    def get_output(self, name):
        code, stdout, err = self.tf.cmd(
            "output %s" % name,
            capture_output=True,
            no_color=IsFlagged
        )
        if code != 0:
            raise Exception("error getting output: %s\n" % err)

        return stdout.rstrip('\n')

    def __init__(self, working_dir):
        self.tf = Terraform(working_dir=working_dir)

    def get_gitlab_storage_service_account_key(self):
        return self.get_output('gitlab_storage_service_account_key')

    def get_gitlab_external_address(self):
        return self.get_output('gitlab_external_address')

    def get_gitlab_instance_dns_record_name(self):
        return self.get_output('gitlab_instance_dns_record_name')

    def get_gitlab_database_name(self):
        return self.get_output('gitlab_database_name')

    def get_gitlab_user_name(self):
        return self.get_output('gitlab_user_name')

    def get_gitlab_user_password(self):
        return self.get_output('gitlab_user_password')

    def get_gitlab_bucket_registry(self):
        return self.get_output('gitlab_bucket_registry')

    def get_gitlab_bucket_lfs(self):
        return self.get_output('gitlab_bucket_lfs')

    def get_gitlab_bucket_artifacts(self):
        return self.get_output('gitlab_bucket_artifacts')

    def get_gitlab_bucket_uploads(self):
        return self.get_output('gitlab_bucket_uploads')

    def get_gitlab_bucket_packages(self):
        return self.get_output('gitlab_bucket_packages')

    def get_gitlab_bucket_externaldiffs(self):
        return self.get_output('gitlab_bucket_externaldiffs')

    def get_gitlab_bucket_pseudonymizer(self):
        return self.get_output('gitlab_bucket_pseudonymizer')

    def get_gitlab_bucket_backup(self):
        return self.get_output('gitlab_bucket_backup')

    def get_gitlab_bucket_backup_tmp(self):
        return self.get_output('gitlab_bucket_backup_tmp')

    def get_storage_sa_email(self):
        return self.get_output('storage_sa_email')
