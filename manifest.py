import yaml
import os


class Manifest():
    def __init__(self, dict):
        self.name = dict['name']
        self.gcp_project = dict['gcp_project']
        self.region = dict['region']
        self.infrastructure = Infrastructure(dict['infrastructure'])
        self.gitlab = Gitlab(dict['gitlab'])
        self.cloudflare = Cloudflare()

    def tf_vars(self):
        
        gitlab = self.gitlab
        cluster = self.infrastructure.cluster
        database = self.infrastructure.cloudsql
        cloudflare = self.cloudflare

        # gitlab's hosts inference
        gitlab_host = 'gitlab'
        registry_host = 'registry'
        if gitlab.host_suffix is not None:
            gitlab_host += '-%s' % gitlab.host_suffix
            registry_host += '-%s' % gitlab.host_suffix
            
        return {
                'cf_email': cloudflare.email,
                'cf_token': cloudflare.token,
                'project_id': self.gcp_project,
                'region': self.region,
                'gke_cluster_name': cluster.name,
                'gke_cluster_zone': cluster.zone,
                'gke_instance_type': cluster.instance_type,
                'buckets_prefix': gitlab.buckets_prefix,
                'database_version': database.version,
                'database_tier': database.instance_type,
                'gitlab_host': gitlab_host,
                'registry_host': registry_host,
                'domain': gitlab.domain,
                'master_auth_ip': cluster.master_auth_ip
            }


class Infrastructure():
    def __init__(self, dict):
        self.cluster = GKECluster(dict['gke_cluster'])
        self.cloudsql = CloudSQL(dict['cloudsql'])


class GKECluster():
    def __init__(self, dict):
        self.name = dict['name']
        self.zone = dict['zone']
        self.instance_type = dict['instance_type']
        self.admins = dict['admins']
        self.master_auth_ip = dict['master_auth_ip']


class CloudSQL():
    def __init__(self, dict):
        self.instance_type = dict['instance_type']
        self.version = dict['version']


class Gitlab():
    def __init__(self, dict):
        self.host_suffix = dict['host_suffix']
        self.domain = dict['domain']
        self.chart_version = dict['chart_version']
        self.buckets_prefix = dict['buckets_prefix']
        self.issuer_email = dict['issuer_email']
        self.s3cmd = S3Cmd()


class S3Cmd():
    def __init__(self):
        self.access_key = os.environ['S3CMD_ACCESS_KEY']
        self.secret_key = os.environ['S3CMD_SECRET_KEY']


class Cloudflare():
    def __init__(self):
        self.email = os.environ['CLOUDFLARE_EMAIL']
        self.token = os.environ['CLOUDFLARE_TOKEN']
