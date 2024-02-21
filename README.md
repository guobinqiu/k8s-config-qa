k8s-config
---

# 涉及到的资源

- Kubernetes服务
  - stagingAKSCluster
- 规模集实例
  - aks-nodepool1-40073806-vmss（3个）
- 容器注册表
  - stagingACR 
- 磁盘
  - 静态挂载
      - giltab-origin
      - mysql-origin
      - postgresql-origin
      - redis-origin 
  - 动态挂载
      - keycloak-pvc
      - data-es-cluster-0
      - data-es-cluster-1
      - data-es-cluster-2
      - date-redis-cluster-0
      - date-redis-cluster-1
      - date-redis-cluster-2
      - date-redis-cluster-3
      - date-redis-cluster-4
      - date-redis-cluster-5
- 负载均衡
  - kubenetes-internal  
- 虚拟机（用作跳板机）
  - couponVM
- 虚拟网络
  - EC2QDLVN01（10.162.66.0/24）
- 虚拟网络子网
  - EC2QDLAPPSN02（10.162.66.240/28）
- 网络接口
  - aks-nodepool1-40073806-vmss
  - couponVMVMNic
- 网络安全组（设置出入站规则）
  - aks-agentpool-40073806-nsg
  - couponVMNSG
- 快照（可经由jenkins定期做磁盘备份）
- Azure Active Directory
  - service-principal
  - client-secret 
- 存储账户（动态挂载磁盘的落脚点）
  - f20c66fc64b284dc8b0122a
- 订阅
  - DataLake-Staging
- 资源组
  - couponResourceGroup 

# AKS集群配置

- Kubernetes版本：1.20.9
- 1个节点池
  - 节点数(--node-count): 3
  - 节点类型(--node-vm-size): `Standard_DS2_v2`
    - OS：Linux
    - CPU核数：2
    - 内存：7G
    - 硬盘：高级SSD LRS 128G
    - 最大IOPS: 500
    - 价格：744.60元/月
  - 启用了自动缩放(--enable-cluster-autoscaler)
  - 每节点最大Pod数(--max-pods)：110
  - 虚拟网络：EC2QDLVN01
  - 虚拟网络子网：EC2QDLAPPSN02
- 身份验证方法：SP(非Managed Identity)
- 启用了RBAC(--enable-azure-rbac)
- 网络插件(--network-plugin)：kubenet（非azure）
- 网络策略(--network-policy)：无（can be calico?）

# 服务

- 入口服务
  - haproxy-ingress：集群网关（1pod）
- 存储服务
	- postgresql：存储gitlab服务的部分数据 （1pod）
	- redis集群：存储gitlab服务的部分数据和卡券相关服务的数据（statefulset，6pods）
	- mysql：存储卡券相关服务的数据 （1pod）
- 内部应用（autoscaling）
   	- accountservice：用户中心
	- coupon-lan-api：卡券中心后端服务（兰蔻）
	- coupon-bio-api：卡券中心后端服务（碧欧泉）
	- coupon-tools-backend：卡券配置中心后端服务
	- coupon-tools-frontend：卡券配置中心前端服务	
	- web-app-demo：测试服务
- 第三方应用
	- gitlab：代码仓库，执行CI，CD（1pod）
	- jenkins：执行定时任务，比如备份，但不执行CI，CD（1pod） 
	- keycloak：卡券中心鉴权服务（1pod）
	- 日志服务
	  - elasticsearch集群（statefulset，3pods）
	  - fluentd（sidecar）
	  - kibana（1pod）
	- 监控服务
	  - prometheus（1pod）
	  - grafana（1pod）
	- 调试服务
	  - telepresence（sidecar）

# TODO

- 代码改造成terraform
- 一个服务一个namespace
