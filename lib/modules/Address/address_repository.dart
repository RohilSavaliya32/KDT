import 'address_api_service.dart';
import 'address_model.dart';

class AddressRepository {
  final AddressApiService api;

  AddressRepository(this.api);

  Future<List<AddressModel>> getAddresses() async {
    final response = await api.getAddresses();

    return (response['data'] as List)
        .map((e) => AddressModel.fromJson(e))
        .toList();
  }

  Future<void> createAddress(AddressModel model) async {
    await api.createAddress(model.toJson());
  }

  Future<void> updateAddress(AddressModel model) async {
    await api.updateAddress(
      model.id,
      model.toJson(),
    );
  }

  Future<void> deleteAddress(String id) async {
    await api.deleteAddress(id);
  }
}