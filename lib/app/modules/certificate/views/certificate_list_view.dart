import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker_app/app/models/certificate_model.dart';
import 'package:job_seeker_app/app/modules/certificate/controllers/certificate_list_controller.dart';
import 'package:job_seeker_app/app/routes/app_pages.dart';

class CertificateListView extends GetView<CertificateListController> {
  const CertificateListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的证书'),
        actions: [
          // 筛选按钮
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Get.toNamed(Routes.CERTIFICATE_EDIT);
          if (result == true) {
            controller.refreshData();
          }
        },
      ),
    );
  }

  // 构建主体内容
  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value && controller.certificates.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.certificates.isEmpty) {
        return _buildEmptyView();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.certificates.length + (controller.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.certificates.length) {
              // 加载更多
              controller.loadMore();
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _buildCertificateCard(controller.certificates[index]);
          },
        ),
      );
    });
  }

  // 构建空视图
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.file_copy_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无证书记录',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Get.toNamed(Routes.CERTIFICATE_EDIT),
            child: const Text('添加证书'),
          ),
        ],
      ),
    );
  }

  // 构建证书卡片
  Widget _buildCertificateCard(Certificate certificate) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showCertificateDetail(certificate),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 证书图片
            if (certificate.imageUrl != null && certificate.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  certificate.fullImageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 证书名称和状态
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          certificate.certificateName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 状态标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(certificate.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          certificate.statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 证书类型
                  if (certificate.certificateTypeName != null)
                    _buildInfoRow(
                      Icons.category,
                      certificate.certificateTypeName!,
                    ),
                  
                  // 证书编号
                  if (certificate.certificateNo != null && certificate.certificateNo!.isNotEmpty)
                    _buildInfoRow(
                      Icons.numbers,
                      certificate.certificateNo!,
                    ),
                  
                  // 发证日期和到期日期
                  if (certificate.issueDate != null && certificate.expiryDate != null)
                    _buildInfoRow(
                      Icons.date_range,
                      '${dateFormat.format(certificate.issueDate!)} 至 ${dateFormat.format(certificate.expiryDate!)}',
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // 操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (certificate.status == CertificateStatus.rejected)
                        TextButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('重新提交'),
                          onPressed: () async {
                            final result = await Get.toNamed(
                              Routes.CERTIFICATE_EDIT,
                              arguments: {'id': certificate.id},
                            );
                            if (result == true) {
                              controller.refreshData();
                            }
                          },
                        ),
                      
                      const SizedBox(width: 8),
                      
                      // 删除按钮
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          '删除',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () => _confirmDelete(certificate),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[800],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 获取状态颜色
  Color _getStatusColor(CertificateStatus status) {
    switch (status) {
      case CertificateStatus.pending:
        return Colors.orange;
      case CertificateStatus.verified:
        return Colors.green;
      case CertificateStatus.rejected:
        return Colors.red;
    }
  }

  // 显示证书详情
  void _showCertificateDetail(Certificate certificate) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 证书图片
            if (certificate.imageUrl != null && certificate.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  certificate.fullImageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 证书名称
                    Text(
                      certificate.certificateName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 状态
                    _buildDetailRow('状态', certificate.statusText),
                    
                    // 证书类型
                    if (certificate.certificateTypeName != null)
                      _buildDetailRow('类型', certificate.certificateTypeName!),
                    
                    // 证书编号
                    if (certificate.certificateNo != null && certificate.certificateNo!.isNotEmpty)
                      _buildDetailRow('编号', certificate.certificateNo!),
                    
                    // 发证机构
                    if (certificate.issuingAuthority != null && certificate.issuingAuthority!.isNotEmpty)
                      _buildDetailRow('发证机构', certificate.issuingAuthority!),
                    
                    // 发证日期
                    if (certificate.issueDate != null)
                      _buildDetailRow('发证日期', dateFormat.format(certificate.issueDate!)),
                    
                    // 到期日期
                    if (certificate.expiryDate != null)
                      _buildDetailRow('到期日期', dateFormat.format(certificate.expiryDate!)),
                    
                    // 审核意见
                    if (certificate.status == CertificateStatus.rejected && 
                        certificate.verificationComment != null && 
                        certificate.verificationComment!.isNotEmpty)
                      _buildDetailRow('拒绝原因', certificate.verificationComment!),
                    
                    const SizedBox(height: 16),
                    
                    // 关闭按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        child: const Text('关闭'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建详情行
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示筛选底部菜单
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '筛选证书',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '状态',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('全部', ''),
                  _buildFilterChip('待审核', 'pending'),
                  _buildFilterChip('已通过', 'verified'),
                  _buildFilterChip('已拒绝', 'rejected'),
                ],
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('确定'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建筛选标签
  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: controller.statusFilter.value == value,
      onSelected: (selected) {
        if (selected) {
          controller.setStatusFilter(value);
          Get.back();
        }
      },
    );
  }

  // 确认删除
  void _confirmDelete(Certificate certificate) {
    Get.dialog(
      AlertDialog(
        title: const Text('删除证书'),
        content: Text('确定要删除《${certificate.certificateName}》证书吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Get.back();
              if (certificate.id != null) {
                controller.deleteCertificate(certificate.id!);
              }
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
} 