// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemModelAdapter extends TypeAdapter<CartItemModel> {
  @override
  final int typeId = 0;

  @override
  CartItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItemModel(
      id: fields[0] as int,
      productId: fields[1] as int,
      quantity: fields[2] as int,
      createdAt: fields[3] as DateTime?,
      productName: fields[4] as String?,
      productImage: fields[5] as String?,
      price: fields[6] as double?,
      subtotal: fields[7] as double?,
      productDescription: fields[8] as String?,
      productOriginalPrice: fields[9] as double?,
      productDiscountPrice: fields[10] as double?,
      productHasDiscount: fields[11] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, CartItemModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.productName)
      ..writeByte(5)
      ..write(obj.productImage)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.subtotal)
      ..writeByte(8)
      ..write(obj.productDescription)
      ..writeByte(9)
      ..write(obj.productOriginalPrice)
      ..writeByte(10)
      ..write(obj.productDiscountPrice)
      ..writeByte(11)
      ..write(obj.productHasDiscount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CartModelAdapter extends TypeAdapter<CartModel> {
  @override
  final int typeId = 1;

  @override
  CartModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartModel(
      items: (fields[0] as List).cast<CartItemModel>(),
      lastUpdated: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CartModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.items)
      ..writeByte(1)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
