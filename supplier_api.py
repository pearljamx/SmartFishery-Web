# -*- coding: utf-8 -*-
# ============================================================
# SmartFishery 供应商管理 API 模块
# 包含供应商、鱼苗产品、采购订单的所有API端点
# ============================================================

from flask import request, jsonify, session
from functools import wraps
from datetime import datetime
from sqlalchemy import func, desc


def register_supplier_apis(app, db, Supplier, SeedlingProduct, SeedlingInventory, PurchaseOrder, OrderItem, User, Pond):
    """注册所有供应商管理API端点"""
    
    # ============================================================
    # 辅助函数
    # ============================================================
    
    def get_current_user():
        """获取当前登录用户"""
        if 'user_id' not in session:
            return None
        return User.query.get(session['user_id'])
    
    
    def log_audit(action, resource_type, resource_id, old_value=None, new_value=None):
        """记录审计日志（如果表存在）"""
        try:
            from sqlalchemy import text
            user_id = session.get('user_id')
            sql = """
            INSERT INTO system_logs 
            (user_id, action, resource_type, resource_id, old_value, new_value, ip_address, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            db.session.execute(text(sql), {
                'user_id': user_id,
                'action': action,
                'resource_type': resource_type,
                'resource_id': resource_id,
                'old_value': old_value,
                'new_value': new_value,
                'ip_address': request.remote_addr,
                'created_at': datetime.utcnow()
            })
            db.session.commit()
        except Exception as e:
            print(f"审计日志记录失败: {e}")
    
    
    # ============================================================
    # 获取当前用户信息 API
    # ============================================================
    
    @app.route('/api/current-user', methods=['GET'])
    def api_current_user():
        """获取当前登录用户信息"""
        try:
            user = get_current_user()
            if not user:
                return jsonify({'status': 'error', 'message': '未登录'}), 401
            
            supplier_name = None
            if user.supplier_id:
                supplier = Supplier.query.get(user.supplier_id)
                supplier_name = supplier.name if supplier else None
            
            return jsonify({
                'status': 'success',
                'data': {
                    'id': user.id,
                    'username': user.username,
                    'role': user.role,
                    'supplier_id': user.supplier_id,
                    'supplier_name': supplier_name,
                    'email': user.email,
                    'full_name': user.full_name
                }
            }), 200
        except Exception as e:
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    # ============================================================
    # 管理员 - 供应商管理 API
    # ============================================================
    
    @app.route('/api/suppliers', methods=['GET'])
    def api_get_suppliers():
        """获取所有供应商列表"""
        try:
            user = get_current_user()
            if not user or user.role != 'admin':
                return jsonify({'status': 'error', 'message': '仅管理员可访问'}), 403
            
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            search = request.args.get('search', '', type=str)
            status = request.args.get('status', '', type=str)
            
            query = Supplier.query
            if search:
                query = query.filter(Supplier.name.like(f'%{search}%'))
            if status:
                query = query.filter_by(status=status)
            
            suppliers = query.paginate(page=page, per_page=per_page)
            
            return jsonify({
                'status': 'success',
                'data': [s.to_dict() for s in suppliers.items],
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': suppliers.total,
                    'pages': suppliers.pages
                }
            }), 200
        except Exception as e:
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    @app.route('/api/suppliers/add', methods=['POST'])
    def api_add_supplier():
        """添加新供应商"""
        try:
            user = get_current_user()
            if not user or user.role != 'admin':
                return jsonify({'status': 'error', 'message': '仅管理员可操作'}), 403
            
            data = request.get_json()
            required_fields = ['name', 'contact_person', 'phone', 'email']
            if not all(data.get(f) for f in required_fields):
                return jsonify({'status': 'error', 'message': '缺少必填字段'}), 400
            
            # 检查供应商是否已存在
            if Supplier.query.filter_by(name=data['name']).first():
                return jsonify({'status': 'error', 'message': '供应商名称已存在'}), 409
            
            supplier = Supplier(
                name=data['name'],
                contact_person=data['contact_person'],
                phone=data['phone'],
                email=data['email'],
                address=data.get('address'),
                registration_date=datetime.utcnow().date() if data.get('registration_date') else None,
                status=data.get('status', 'active'),
                notes=data.get('notes')
            )
            
            db.session.add(supplier)
            db.session.commit()
            
            log_audit('create_supplier', 'suppliers', supplier.id, new_value=str(data))
            
            return jsonify({
                'status': 'success',
                'message': '供应商创建成功',
                'data': supplier.to_dict()
            }), 201
        except Exception as e:
            db.session.rollback()
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    @app.route('/api/suppliers/<int:supplier_id>/edit', methods=['POST'])
    def api_edit_supplier(supplier_id):
        """编辑供应商信息"""
        try:
            user = get_current_user()
            if not user or user.role != 'admin':
                return jsonify({'status': 'error', 'message': '仅管理员可操作'}), 403
            
            supplier = Supplier.query.get(supplier_id)
            if not supplier:
                return jsonify({'status': 'error', 'message': '供应商不存在'}), 404
            
            data = request.get_json()
            old_value = str(supplier.to_dict())
            
            supplier.name = data.get('name', supplier.name)
            supplier.contact_person = data.get('contact_person', supplier.contact_person)
            supplier.phone = data.get('phone', supplier.phone)
            supplier.email = data.get('email', supplier.email)
            supplier.address = data.get('address', supplier.address)
            supplier.status = data.get('status', supplier.status)
            supplier.notes = data.get('notes', supplier.notes)
            
            db.session.commit()
            log_audit('update_supplier', 'suppliers', supplier_id, old_value=old_value, new_value=str(data))
            
            return jsonify({
                'status': 'success',
                'message': '供应商信息更新成功',
                'data': supplier.to_dict()
            }), 200
        except Exception as e:
            db.session.rollback()
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    @app.route('/api/suppliers/<int:supplier_id>', methods=['GET'])
    def api_get_supplier(supplier_id):
        """获取供应商详情"""
        try:
            user = get_current_user()
            if not user or user.role != 'admin':
                return jsonify({'status': 'error', 'message': '仅管理员可访问'}), 403
            
            supplier = Supplier.query.get(supplier_id)
            if not supplier:
                return jsonify({'status': 'error', 'message': '供应商不存在'}), 404
            
            # 统计信息
            product_count = SeedlingProduct.query.filter_by(supplier_id=supplier_id).count()
            order_count = PurchaseOrder.query.filter_by(supplier_id=supplier_id).count()
            total_amount = db.session.query(func.sum(PurchaseOrder.total_amount)).filter_by(supplier_id=supplier_id).scalar() or 0
            
            supplier_data = supplier.to_dict()
            supplier_data['product_count'] = product_count
            supplier_data['order_count'] = order_count
            supplier_data['total_amount'] = float(total_amount)
            
            return jsonify({
                'status': 'success',
                'data': supplier_data
            }), 200
        except Exception as e:
            return jsonify({'status': 'error', 'message': str(e)}), 500


    @app.route('/api/suppliers/<int:supplier_id>/delete', methods=['DELETE'])
    def api_delete_supplier(supplier_id):
        """删除供应商"""
        try:
            user = get_current_user()
            if not user or user.role != 'admin':
                return jsonify({'status': 'error', 'message': '仅管理员可操作'}), 403
            
            supplier = Supplier.query.get(supplier_id)
            if not supplier:
                return jsonify({'status': 'error', 'message': '供应商不存在'}), 404
            
            # 检查是否有关联的产品或订单
            product_count = SeedlingProduct.query.filter_by(supplier_id=supplier_id).count()
            order_count = PurchaseOrder.query.filter_by(supplier_id=supplier_id).count()
            
            if product_count > 0 or order_count > 0:
                return jsonify({
                    'status': 'error',
                    'message': f'无法删除：该供应商有 {product_count} 个产品和 {order_count} 个订单'
                }), 409
            
            supplier_name = supplier.name
            db.session.delete(supplier)
            db.session.commit()
            
            # 审计日志
            log_audit('delete_supplier', 'suppliers', supplier_id, 
                     old_value=f"删除的供应商: {supplier_name}",
                     new_value='已删除')
            
            return jsonify({
                'status': 'success',
                'message': f'供应商"{supplier_name}"删除成功'
            }), 200
        except Exception as e:
            db.session.rollback()
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    # ============================================================
    # 管理员 - 采购订单管理 API
    # ============================================================
    
    @app.route('/api/purchase-orders', methods=['GET'])
    def api_get_purchase_orders():
        """获取采购订单列表（管理员可看全部，供应商只能看自己的）"""
        try:
            user = get_current_user()
            if not user:
                return jsonify({'status': 'error', 'message': '未登录'}), 401
            
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            status_filter = request.args.get('status', '', type=str)
            
            query = PurchaseOrder.query
            
            # 供应商只能看自己的订单
            if user.role == 'supplier' and user.supplier_id:
                query = query.filter_by(supplier_id=user.supplier_id)
            elif user.role != 'admin':
                return jsonify({'status': 'error', 'message': '没有权限访问'}), 403
            
            if status_filter:
                query = query.filter_by(status=status_filter)
            
            orders = query.order_by(desc(PurchaseOrder.created_at)).paginate(page=page, per_page=per_page)
            
            return jsonify({
                'status': 'success',
                'data': [o.to_dict() for o in orders.items],
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': orders.total,
                    'pages': orders.pages
                }
            }), 200
        except Exception as e:
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    @app.route('/api/purchase-orders/create', methods=['POST'])
    def api_create_purchase_order():
        """创建采购订单（管理员操作）"""
        try:
            user = get_current_user()
            if not user or user.role != 'admin':
                return jsonify({'status': 'error', 'message': '仅管理员可创建订单'}), 403
            
            data = request.get_json()
            required = ['supplier_id', 'pond_id', 'items']
            if not all(data.get(f) for f in required):
                return jsonify({'status': 'error', 'message': '缺少必填字段'}), 400
            
            supplier = Supplier.query.get(data['supplier_id'])
            pond = Pond.query.get(data['pond_id'])
            
            if not supplier or not pond:
                return jsonify({'status': 'error', 'message': '供应商或鱼池不存在'}), 404
            
            # 创建订单
            order = PurchaseOrder(
                supplier_id=data['supplier_id'],
                pond_id=data['pond_id'],
                created_by=user.id,
                expected_delivery_date=data.get('expected_delivery_date'),
                status=data.get('status', 'draft'),
                notes=data.get('notes')
            )
            
            # 添加订单项
            total_amount = 0
            for item in data['items']:
                product = SeedlingProduct.query.get(item['product_id'])
                if not product:
                    return jsonify({'status': 'error', 'message': f'产品 {item["product_id"]} 不存在'}), 404
                
                order_item = OrderItem(
                    product_id=item['product_id'],
                    quantity=item['quantity'],
                    unit_price=item.get('unit_price', product.unit_price)
                )
                order.items.append(order_item)
                total_amount += order_item.quantity * order_item.unit_price
            
            order.total_amount = total_amount
            db.session.add(order)
            db.session.commit()
            
            log_audit('create_purchase_order', 'purchase_orders', order.id, new_value=str(data))
            
            return jsonify({
                'status': 'success',
                'message': '采购订单创建成功',
                'data': order.to_dict()
            }), 201
        except Exception as e:
            db.session.rollback()
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    # ============================================================
    # 商家 - 鱼苗产品管理 API
    # ============================================================
    
    @app.route('/api/my-products', methods=['GET'])
    def api_get_my_products():
        """获取我的鱼苗产品列表"""
        try:
            user = get_current_user()
            if not user or user.role != 'supplier' or not user.supplier_id:
                return jsonify({'status': 'error', 'message': '仅供应商可访问'}), 403
            
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            species = request.args.get('species', '', type=str)
            
            query = SeedlingProduct.query.filter_by(supplier_id=user.supplier_id)
            if species:
                query = query.filter_by(species=species)
            
            products = query.paginate(page=page, per_page=per_page)
            
            # 获取库存信息
            product_list = []
            for product in products.items:
                p_dict = product.to_dict()
                inventory = SeedlingInventory.query.filter_by(
                    supplier_id=user.supplier_id,
                    product_id=product.id
                ).first()
                p_dict['inventory'] = inventory.quantity if inventory else 0
                product_list.append(p_dict)
            
            return jsonify({
                'status': 'success',
                'data': product_list,
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': products.total,
                    'pages': products.pages
                }
            }), 200
        except Exception as e:
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    @app.route('/api/my-products/add', methods=['POST'])
    def api_add_product():
        """添加新产品"""
        try:
            user = get_current_user()
            if not user or user.role != 'supplier' or not user.supplier_id:
                return jsonify({'status': 'error', 'message': '仅供应商可操作'}), 403
            
            data = request.get_json()
            required = ['product_name', 'species', 'unit_price']
            if not all(data.get(f) for f in required):
                return jsonify({'status': 'error', 'message': '缺少必填字段'}), 400
            
            product = SeedlingProduct(
                supplier_id=user.supplier_id,
                product_name=data['product_name'],
                species=data['species'],
                grade=data.get('grade'),
                unit_price=float(data['unit_price']),
                cost_price=float(data.get('cost_price', 0)),
                growth_cycle_days=data.get('growth_cycle_days'),
                survival_rate=float(data.get('survival_rate', 100)),
                image_url=data.get('image_url'),
                description=data.get('description'),
                is_active=data.get('is_active', True)
            )
            
            db.session.add(product)
            db.session.flush()  # 获取product id
            
            # 初始化库存
            inventory = SeedlingInventory(
                supplier_id=user.supplier_id,
                product_id=product.id,
                quantity=data.get('initial_quantity', 0),
                updated_by=user.username
            )
            db.session.add(inventory)
            db.session.commit()
            
            log_audit('create_product', 'seedling_products', product.id, new_value=str(data))
            
            return jsonify({
                'status': 'success',
                'message': '产品创建成功',
                'data': product.to_dict()
            }), 201
        except Exception as e:
            db.session.rollback()
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    @app.route('/api/my-products/<int:product_id>/inventory', methods=['PUT'])
    def api_update_inventory(product_id):
        """更新库存"""
        try:
            user = get_current_user()
            if not user or user.role != 'supplier' or not user.supplier_id:
                return jsonify({'status': 'error', 'message': '仅供应商可操作'}), 403
            
            product = SeedlingProduct.query.filter_by(
                id=product_id,
                supplier_id=user.supplier_id
            ).first()
            
            if not product:
                return jsonify({'status': 'error', 'message': '产品不存在'}), 404
            
            data = request.get_json()
            quantity = data.get('quantity')
            
            if quantity is None:
                return jsonify({'status': 'error', 'message': '缺少数量字段'}), 400
            
            inventory = SeedlingInventory.query.filter_by(
                supplier_id=user.supplier_id,
                product_id=product_id
            ).first()
            
            if not inventory:
                inventory = SeedlingInventory(
                    supplier_id=user.supplier_id,
                    product_id=product_id
                )
                db.session.add(inventory)
            
            old_qty = inventory.quantity
            inventory.quantity = int(quantity)
            inventory.updated_by = user.username
            
            db.session.commit()
            
            log_audit('update_inventory', 'seedling_inventory', inventory.id,
                     old_value=f'quantity={old_qty}',
                     new_value=f'quantity={quantity}')
            
            return jsonify({
                'status': 'success',
                'message': '库存更新成功',
                'data': inventory.to_dict()
            }), 200
        except Exception as e:
            db.session.rollback()
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    # ============================================================
    # 商家 - 订单管理 API
    # ============================================================
    
    @app.route('/api/my-orders', methods=['GET'])
    def api_get_my_orders():
        """获取我收到的采购订单"""
        try:
            user = get_current_user()
            if not user or user.role != 'supplier' or not user.supplier_id:
                return jsonify({'status': 'error', 'message': '仅供应商可访问'}), 403
            
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            status_filter = request.args.get('status', '', type=str)
            
            query = PurchaseOrder.query.filter_by(supplier_id=user.supplier_id)
            if status_filter:
                query = query.filter_by(status=status_filter)
            
            orders = query.order_by(desc(PurchaseOrder.created_at)).paginate(page=page, per_page=per_page)
            
            return jsonify({
                'status': 'success',
                'data': [o.to_dict() for o in orders.items],
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': orders.total,
                    'pages': orders.pages
                }
            }), 200
        except Exception as e:
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    @app.route('/api/my-orders/<int:order_id>/update-status', methods=['POST'])
    def api_update_order_status(order_id):
        """更新订单状态"""
        try:
            user = get_current_user()
            if not user or user.role != 'supplier' or not user.supplier_id:
                return jsonify({'status': 'error', 'message': '仅供应商可操作'}), 403
            
            order = PurchaseOrder.query.filter_by(
                id=order_id,
                supplier_id=user.supplier_id
            ).first()
            
            if not order:
                return jsonify({'status': 'error', 'message': '订单不存在'}), 404
            
            data = request.get_json()
            new_status = data.get('status')
            
            # 允许的状态流转
            allowed_transitions = {
                'draft': ['confirmed'],
                'confirmed': ['shipped'],
                'shipped': ['received']
            }
            
            if new_status not in allowed_transitions.get(order.status, []):
                return jsonify({'status': 'error', 'message': f'无法从{order.status}转为{new_status}'}), 400
            
            old_status = order.status
            order.status = new_status
            
            if new_status == 'shipped':
                order.actual_delivery_date = data.get('delivery_date')
            
            db.session.commit()
            
            log_audit('update_order_status', 'purchase_orders', order_id,
                     old_value=old_status, new_value=new_status)
            
            return jsonify({
                'status': 'success',
                'message': f'订单状态已更新为 {new_status}',
                'data': order.to_dict()
            }), 200
        except Exception as e:
            db.session.rollback()
            return jsonify({'status': 'error', 'message': str(e)}), 500
    
    
    # ============================================================
    # 商家 - 财务统计 API
    # ============================================================
    
    @app.route('/api/my-sales-stats', methods=['GET'])
    def api_get_sales_stats():
        """获取销售统计数据"""
        try:
            user = get_current_user()
            if not user or user.role != 'supplier' or not user.supplier_id:
                return jsonify({'status': 'error', 'message': '仅供应商可访问'}), 403
            
            # 查询所有订单
            orders = PurchaseOrder.query.filter_by(supplier_id=user.supplier_id).all()
            
            # 统计数据
            total_sales = sum(o.total_amount for o in orders)
            total_orders = len(orders)
            
            # 按状态统计
            status_stats = {}
            for order in orders:
                status_stats[order.status] = status_stats.get(order.status, 0) + 1
            
            # 按产品统计销售
            product_stats = {}
            for order in orders:
                for item in order.items:
                    if item.product_id not in product_stats:
                        product_stats[item.product_id] = {'quantity': 0, 'amount': 0}
                    product_stats[item.product_id]['quantity'] += item.quantity
                    product_stats[item.product_id]['amount'] += item.quantity * item.unit_price
            
            return jsonify({
                'status': 'success',
                'data': {
                    'total_sales': float(total_sales),
                    'total_orders': total_orders,
                    'status_distribution': status_stats,
                    'product_sales': product_stats
                }
            }), 200
        except Exception as e:
            return jsonify({'status': 'error', 'message': str(e)}), 500

    # ============================================================
    # 管理员产品管理 API (Task1)
    # ============================================================

    @app.route('/api/products', methods=['GET'])
    def get_all_products():
        """获取所有鱼苗产品列表（管理员）"""
        try:
            if session.get('role') != 'admin':
                return jsonify({'status': 'error', 'message': '仅管理员可访问'}), 403
            
            products = SeedlingProduct.query.all()
            product_list = []
            
            for p in products:
                supplier = Supplier.query.get(p.supplier_id)
                product_list.append({
                    'id': p.id,
                    'product_name': p.product_name,
                    'species': p.species,
                    'grade': p.grade,
                    'unit_price': p.unit_price,
                    'cost_price': p.cost_price,
                    'growth_cycle_days': p.growth_cycle_days,
                    'survival_rate': p.survival_rate,
                    'is_active': p.is_active,
                    'supplier_id': p.supplier_id,
                    'supplier_name': supplier.name if supplier else '未知供应商',
                    'created_at': p.created_at.isoformat() if p.created_at else None
                })
            
            return jsonify({'status': 'success', 'data': product_list}), 200
        except Exception as e:
            return jsonify({'status': 'error', 'message': str(e)}), 500

    @app.route('/api/products/<int:product_id>', methods=['GET'])
    def get_product_detail(product_id):
        """获取单个产品详情（查看产品功能）"""
        try:
            if session.get('role') != 'admin':
                return jsonify({'status': 'error', 'message': '仅管理员可访问'}), 403
            
            product = SeedlingProduct.query.get(product_id)
            if not product:
                return jsonify({'status': 'error', 'message': '产品不存在'}), 404
            
            supplier = Supplier.query.get(product.supplier_id)
            
            return jsonify({
                'status': 'success',
                'data': {
                    'id': product.id,
                    'product_name': product.product_name,
                    'species': product.species,
                    'grade': product.grade,
                    'unit_price': product.unit_price,
                    'cost_price': product.cost_price,
                    'growth_cycle_days': product.growth_cycle_days,
                    'survival_rate': product.survival_rate,
                    'description': product.description,
                    'image_url': product.image_url,
                    'is_active': product.is_active,
                    'supplier_id': product.supplier_id,
                    'supplier_name': supplier.name if supplier else '未知供应商',
                    'supplier_phone': supplier.phone if supplier else '未知',
                    'created_at': product.created_at.isoformat() if product.created_at else None,
                    'updated_at': product.updated_at.isoformat() if product.updated_at else None
                }
            }), 200
        except Exception as e:
            return jsonify({'status': 'error', 'message': str(e)}), 500

    @app.route('/api/products/<int:product_id>/edit', methods=['POST'])
    def edit_product(product_id):
        """编辑产品信息"""
        try:
            if session.get('role') != 'admin':
                return jsonify({'status': 'error', 'message': '仅管理员可访问'}), 403
            
            product = SeedlingProduct.query.get(product_id)
            if not product:
                return jsonify({'status': 'error', 'message': '产品不存在'}), 404
            
            data = request.get_json()
            
            # 更新字段
            if 'product_name' in data:
                product.product_name = data['product_name']
            if 'species' in data:
                product.species = data['species']
            if 'grade' in data:
                product.grade = data['grade']
            if 'unit_price' in data:
                product.unit_price = float(data['unit_price'])
            if 'cost_price' in data:
                product.cost_price = float(data['cost_price']) if data['cost_price'] else None
            if 'growth_cycle_days' in data:
                product.growth_cycle_days = int(data['growth_cycle_days']) if data['growth_cycle_days'] else None
            if 'survival_rate' in data:
                product.survival_rate = float(data['survival_rate']) if data['survival_rate'] else None
            if 'description' in data:
                product.description = data['description']
            if 'is_active' in data:
                product.is_active = data['is_active']
            
            product.updated_at = datetime.utcnow()
            db.session.commit()
            
            # 审计日志
            log_audit('edit', 'SeedlingProduct', product_id, 
                     old_value=f"更新前的产品: {product.product_name}", 
                     new_value=f"更新后的产品: {product.product_name}")
            
            return jsonify({
                'status': 'success',
                'message': '产品更新成功',
                'data': product.to_dict()
            }), 200
        except Exception as e:
            db.session.rollback()
            return jsonify({'status': 'error', 'message': str(e)}), 500

    @app.route('/api/products/<int:product_id>/delete', methods=['DELETE'])
    def delete_product(product_id):
        """删除产品"""
        try:
            if session.get('role') != 'admin':
                return jsonify({'status': 'error', 'message': '仅管理员可访问'}), 403
            
            product = SeedlingProduct.query.get(product_id)
            if not product:
                return jsonify({'status': 'error', 'message': '产品不存在'}), 404
            
            product_name = product.product_name
            
            # 检查是否有订单项引用此产品
            order_items = OrderItem.query.filter_by(product_id=product_id).count()
            if order_items > 0:
                return jsonify({
                    'status': 'error',
                    'message': f'无法删除：该产品已被 {order_items} 个订单引用'
                }), 409
            
            # 删除库存记录
            SeedlingInventory.query.filter_by(product_id=product_id).delete()
            
            # 删除产品
            db.session.delete(product)
            db.session.commit()
            
            # 审计日志
            log_audit('delete', 'SeedlingProduct', product_id,
                     old_value=f"删除的产品: {product_name}",
                     new_value='已删除')
            
            return jsonify({
                'status': 'success',
                'message': f'产品"{product_name}"删除成功'
            }), 200
        except Exception as e:
            db.session.rollback()
            return jsonify({'status': 'error', 'message': str(e)}), 500

print("[OK] 供应商管理API模块已加载")
