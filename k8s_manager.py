import base64
import json
from kubernetes import client, config
from kubernetes.client.rest import ApiException


class K8sManager(object):

    def __init__(self):
        config.load_kube_config()

    def apply_service_account(self, name, namespace=None):
        """
        Create or Update a ServiceAccount.

        :param str name: the ServiceAccount name (required)
        :param str namespace: the namespace in which to add the resource.
        """

        api_instance = client.CoreV1Api()
        body = client.V1ServiceAccount(
            metadata=client.V1ObjectMeta(
                namespace=namespace,
                name=name,
            )
        )

        try:
            _ = api_instance.read_namespaced_service_account(name, namespace)

        except ApiException as e:
            if e.status == 404:
                try:
                    api_instance.create_namespaced_service_account(
                        namespace=namespace,
                        body=body,
                        pretty=str(True)
                    )

                except ApiException as e:
                    raise ValueError(
                        "Exception when calling CoreV1Api->create_namespaced_service_account: %s\n" % e
                    )
            else:
                raise ValueError(
                    "Exception when calling CoreV1Api->read_namespaced_service_account: %s\n" % e
                )

        try:
            api_instance.replace_namespaced_service_account(
                name=name,
                namespace=namespace,
                body=body,
                pretty=str(True)
            )

        except ApiException as e:
            raise ValueError(
                "Exception when calling CoreV1Api->replace_namespaced_service_account: %s\n" % e
            )

    def apply_cluster_admin_role_binding_to_user(self, name, namespace=None):
        self.apply_clusterrole_binding(
            'User', name, 'cluster-admin', namespace)

    def apply_cluster_admin_role_binding_to_serviceaccount(self, name, namespace=None):
        self.apply_clusterrole_binding(
            'ServiceAccount', name, 'cluster-admin', namespace)

    def apply_clusterrole_binding(self, kind, name, role, namespace=None):
        """
        Create or Update a ClusterRoleBinding.

        :param str kind: the subject kind (required)
        :param str name: the subject name (required)
        :param str role: the role to bind (required)
        :param str namespace: the namespace in which to add the resource.
        """

        api_instance = client.RbacAuthorizationV1Api()
        body = client.V1ClusterRoleBinding(
            role_ref=client.V1RoleRef(
                api_group='rbac.authorization.k8s.io',
                kind='ClusterRole',
                name=role
            ),
            subjects=[
                client.V1Subject(
                    kind=kind,
                    namespace=namespace,
                    name=name
                )
            ],
            metadata=client.V1ObjectMeta(
                name='%s-binding' % name,
            )
        )

        try:
            _ = api_instance.read_cluster_role_binding('%s-binding' % name)

        except ApiException as e:
            if e.status == 404:
                try:
                    api_instance.create_cluster_role_binding(
                        body,
                        pretty=str(True)
                    )

                except ApiException as e:
                    raise ValueError(
                        "Exception when calling RbacAuthorizationV1Api->create_cluster_role_binding: %s\n" % e
                    )
            else:
                raise ValueError(
                    "Exception when calling RbacAuthorizationV1Api->read_cluster_role_binding: %s\n" % e
                )

        try:
            api_instance.replace_cluster_role_binding(
                name='%s-binding' % name,
                body=body,
                pretty=str(True)
            )

        except ApiException as e:
            raise ValueError(
                "Exception when calling RbacAuthorizationV1Api->replace_cluster_role_binding: %s\n" % e
            )

    def apply_secret(self, name, data, namespace='default'):
        """
        Create or Update a Secret.

        :param str name: the secret name (required)
        :param dict data: the secret data (required)
        :param str namespace: the namespace in which to add the resource.
        """

        api_instance = client.CoreV1Api()
        body = client.V1Secret(
            metadata=client.V1ObjectMeta(
                name=name,
                namespace=namespace
            ),
            data=data
        )

        try:
            _ = api_instance.read_namespaced_secret(name, namespace)

        except ApiException as e:
            if e.status == 404:
                try:
                    api_instance.create_namespaced_secret(
                        namespace=namespace,
                        body=body,
                        pretty=str(True)
                    )

                except ApiException as e:
                    raise ValueError(
                        "Exception when calling CoreV1Api->create_namespaced_secret: %s\n" % e
                    )
            else:
                raise ValueError(
                    "Exception when calling CoreV1Api->read_namespaced_secret: %s\n" % e
                )

        try:
            api_instance.replace_namespaced_secret(
                name=name,
                namespace=namespace,
                body=body,
                pretty=str(True)
            )

        except ApiException as e:
            raise ValueError(
                "Exception when calling CoreV1Api->replace_namespaced_secret: %s\n" % e
            )


    def apply_secret_unencoded(self, name, string_data, namespace='default'):
            """
            Create or Update a Secret.

            :param str name: the secret name (required)
            :param dict string_data: the secret string_data (required)
            :param str namespace: the namespace in which to add the resource.
            """

            api_instance = client.CoreV1Api()
            body = client.V1Secret(
                metadata=client.V1ObjectMeta(
                    name=name,
                    namespace=namespace
                ),
                string_data=string_data
            )

            try:
                _ = api_instance.read_namespaced_secret(name, namespace)

            except ApiException as e:
                if e.status == 404:
                    try:
                        api_instance.create_namespaced_secret(
                            namespace=namespace,
                            body=body,
                            pretty=str(True)
                        )

                    except ApiException as e:
                        raise ValueError(
                            "Exception when calling CoreV1Api->create_namespaced_secret: %s\n" % e
                        )
                else:
                    raise ValueError(
                        "Exception when calling CoreV1Api->read_namespaced_secret: %s\n" % e
                    )

            try:
                api_instance.replace_namespaced_secret(
                    name=name,
                    namespace=namespace,
                    body=body,
                    pretty=str(True)
                )

            except ApiException as e:
                raise ValueError(
                    "Exception when calling CoreV1Api->replace_namespaced_secret: %s\n" % e
                )
