import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/address_model.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/location_provider.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/view/base/custom_app_bar.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_text_field.dart';
import 'package:flutter_restaurant/view/screens/address/select_location_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddNewAddressScreen extends StatefulWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel address;
  AddNewAddressScreen({this.isEnableUpdate = false, this.address, this.fromCheckout = false});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final List<Branches> _branches = [];
  GoogleMapController _controller;
  CameraPosition _cameraPosition;

  @override
  void initState() {
    super.initState();

    _branches.addAll(Provider.of<SplashProvider>(context, listen: false).configModel.branches);
    Provider.of<LocationProvider>(context, listen: false).initializeAllAddressType(context: context);
    Provider.of<LocationProvider>(context, listen: false).updateAddressStatusMessae(message: '');
    Provider.of<LocationProvider>(context, listen: false).updateErrorMessage(message: '');
    if (widget.isEnableUpdate && widget.address != null) {
      Provider.of<LocationProvider>(context, listen: false)
          .updatePosition(CameraPosition(target: LatLng(double.parse(widget.address.latitude), double.parse(widget.address.longitude))), true, context);
      _locationController.text = '${widget.address.address}';
      _contactPersonNameController.text = '${widget.address.contactPersonName}';
      _contactPersonNumberController.text = '${widget.address.contactPersonNumber}';
      if (widget.address.addressType == 'Home') {
        Provider.of<LocationProvider>(context, listen: false).updateAddressIndex(0, false);
      } else if (widget.address.addressType == 'Workplace') {
        Provider.of<LocationProvider>(context, listen: false).updateAddressIndex(1, false);
      } else {
        Provider.of<LocationProvider>(context, listen: false).updateAddressIndex(2, false);
      }
    }else {
      _contactPersonNameController.text = '${Provider.of<ProfileProvider>(context, listen: false).userInfoModel.fName ?? ''}'
          ' ${Provider.of<ProfileProvider>(context, listen: false).userInfoModel.lName ?? ''}';
      _contactPersonNumberController.text = Provider.of<ProfileProvider>(context, listen: false).userInfoModel.phone ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context: context, title: widget.isEnableUpdate ? getTranslated('update_address', context) : getTranslated('add_new_address', context)),
      body: Padding(
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
        child: Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            if (locationProvider.address != null) {
              _locationController.text = '${locationProvider.address.name ?? ''}'
                  ' ${locationProvider.address.subAdministrativeArea ?? ''}'
                  ' ${locationProvider.address.isoCountryCode ?? ''}';
            }

            return Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(12.0),
                      child: Center(
                        child: SizedBox(
                          width: 1170,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                     //   physics: BouncingScrollPhysics(),
                            children: [
                              Container(
                                height: 126,
                                width: MediaQuery.of(context).size.width,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
                                  child: Stack(
                                    clipBehavior: Clip.none, children: [
                                      GoogleMap(
                                        mapType: MapType.normal,
                                        initialCameraPosition: CameraPosition(
                                          target: widget.isEnableUpdate
                                              ? LatLng(double.parse(widget.address.latitude) ?? double.parse(_branches[0].latitude), double.parse(widget.address.longitude) ?? double.parse(_branches[0].longitude))
                                              : LatLng(locationProvider.position.latitude  == 0.0 ? double.parse(_branches[0].latitude): locationProvider.position.latitude, locationProvider.position.longitude == 0.0? double.parse(_branches[0].longitude): locationProvider.position.longitude),
                                          zoom: 8,
                                        ),
                                        onTap: (latLng) {
                                          Navigator.pushNamed(
                                            context, Routes.getSelectLocationRoute(),
                                            arguments: SelectLocationScreen(googleMapController: _controller),
                                          );
                                        },
                                        zoomControlsEnabled: false,
                                        compassEnabled: false,
                                        indoorViewEnabled: true,
                                        mapToolbarEnabled: false,
                                        onCameraIdle: () {
                                          locationProvider.updatePosition(_cameraPosition, true, context);
                                        },
                                        onCameraMove: ((_position) => _cameraPosition = _position),
                                        onMapCreated: (GoogleMapController controller) {
                                          _controller = controller;
                                          if (!widget.isEnableUpdate && _controller != null) {
                                            Provider.of<LocationProvider>(context, listen: false).getCurrentLocation(context, true, mapController: _controller);
                                          }
                                        },
                                      ),
                                      locationProvider.loading ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme
                                          .of(context).primaryColor))) : SizedBox(),
                                      Container(
                                          width: MediaQuery.of(context).size.width,
                                          alignment: Alignment.center,
                                          height: MediaQuery.of(context).size.height,
                                          child: Image.asset(
                                            Images.marker,
                                            width: 25,
                                            height: 35,
                                          )),
                                      Positioned(
                                        bottom: 10,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () {
                                            locationProvider.getCurrentLocation(context, true, mapController: _controller);
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
                                              color: ColorResources.COLOR_WHITE,
                                            ),
                                            child: Icon(
                                              Icons.my_location,
                                              color: Theme.of(context).primaryColor,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Center(
                                    child: Text(
                                      getTranslated('add_the_location_correctly', context),
                                      style:
                                      Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getGreyBunkerColor(context), fontSize: Dimensions.FONT_SIZE_SMALL),
                                    )),
                              ),

                              // for label us
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24.0),
                                child: Text(
                                  getTranslated('label_us', context),
                                  style:
                                  Theme.of(context).textTheme.headline3.copyWith(color: ColorResources.getGreyBunkerColor(context), fontSize: Dimensions.FONT_SIZE_LARGE),
                                ),
                              ),

                              Container(
                                height: 50,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                 // physics: BouncingScrollPhysics(),
                                  itemCount: locationProvider.getAllAddressType.length,
                                  itemBuilder: (context, index) => InkWell(
                                    onTap: () {
                                      locationProvider.updateAddressIndex(index, true);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_DEFAULT, horizontal: Dimensions.PADDING_SIZE_LARGE),
                                      margin: EdgeInsets.only(right: 17),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.PADDING_SIZE_SMALL,
                                          ),
                                          border: Border.all(
                                              color:
                                              locationProvider.selectAddressIndex == index ? Theme.of(context).primaryColor : ColorResources.BORDER_COLOR),
                                          color: locationProvider.selectAddressIndex == index ? Theme.of(context).primaryColor : ColorResources.SEARCH_BG),
                                      child: Text(
                                        getTranslated(locationProvider.getAllAddressType[index].toLowerCase(), context),
                                        style: Theme.of(context).textTheme.headline2.copyWith(
                                            color: locationProvider.selectAddressIndex == index ? ColorResources.COLOR_WHITE : ColorResources.COLOR_BLACK),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24.0),
                                child: Text(
                                  getTranslated('delivery_address', context),
                                  style:
                                  Theme.of(context).textTheme.headline3.copyWith(color: ColorResources.getGreyBunkerColor(context), fontSize: Dimensions.FONT_SIZE_LARGE),
                                ),
                              ),

                              // for Address Field
                              Text(
                                getTranslated('address_line_01', context),
                                style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                              CustomTextField(
                                hintText: getTranslated('address_line_02', context),
                                isShowBorder: true,
                                inputType: TextInputType.streetAddress,
                                inputAction: TextInputAction.next,
                                focusNode: _addressNode,
                                nextFocus: _nameNode,
                                controller: _locationController,
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                              // for Contact Person Name
                              Text(
                                getTranslated('contact_person_name', context),
                                style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                              CustomTextField(
                                hintText: getTranslated('enter_contact_person_name', context),
                                isShowBorder: true,
                                inputType: TextInputType.name,
                                controller: _contactPersonNameController,
                                focusNode: _nameNode,
                                nextFocus: _numberNode,
                                inputAction: TextInputAction.next,
                                capitalization: TextCapitalization.words,
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                              // for Contact Person Number
                              Text(
                                getTranslated('contact_person_number', context),
                                style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                              CustomTextField(
                                hintText: getTranslated('enter_contact_person_number', context),
                                isShowBorder: true,
                                inputType: TextInputType.phone,
                                inputAction: TextInputAction.done,
                                focusNode: _numberNode,
                                controller: _contactPersonNumberController,
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                              SizedBox(
                                height: Dimensions.PADDING_SIZE_DEFAULT,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                locationProvider.addressStatusMessage != null
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    locationProvider.addressStatusMessage.length > 0 ? CircleAvatar(backgroundColor: Colors.green, radius: 5) : SizedBox.shrink(),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locationProvider.addressStatusMessage ?? "",
                        style:
                        Theme.of(context).textTheme.headline2.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Colors.green, height: 1),
                      ),
                    )
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    locationProvider.errorMessage.length > 0
                        ? CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 5)
                        : SizedBox.shrink(),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locationProvider.errorMessage ?? "",
                        style: Theme.of(context)
                            .textTheme
                            .headline2
                            .copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).primaryColor, height: 1),
                      ),
                    )
                  ],
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                Container(
                  height: 50.0,
                  width: 1170,
                  child: !locationProvider.isLoading ? CustomButton(
                    btnTxt: widget.isEnableUpdate ? getTranslated('update_address', context) : getTranslated('save_location', context),
                    onTap: locationProvider.loading ? null : () {
                      List<Branches> _branches = Provider.of<SplashProvider>(context, listen: false).configModel.branches;
                      bool _isAvailable = _branches.length == 1 && (_branches[0].latitude == null || _branches[0].latitude.isEmpty);
                      if(!_isAvailable) {
                        for (Branches branch in _branches) {
                          double _distance = Geolocator.distanceBetween(
                            double.parse(branch.latitude), double.parse(branch.longitude),
                            locationProvider.position.latitude, locationProvider.position.longitude,
                          ) / 1000;
                          if (_distance < branch.coverage) {
                            _isAvailable = true;
                            break;
                          }
                        }
                      }
                      if(!_isAvailable) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(getTranslated('service_is_not_available', context)),
                          backgroundColor: Colors.red,
                        ));
                      }else {
                        AddressModel addressModel = AddressModel(
                          addressType: locationProvider.getAllAddressType[locationProvider.selectAddressIndex],
                          contactPersonName: _contactPersonNameController.text ?? '',
                          contactPersonNumber: _contactPersonNumberController.text ?? '',
                          address: _locationController.text ?? '',
                          latitude: widget.isEnableUpdate ? locationProvider.position.latitude.toString() ?? widget.address.latitude
                              : locationProvider.position.latitude.toString() ?? '',
                          longitude: locationProvider.position.longitude.toString() ?? '',
                        );
                        if (widget.isEnableUpdate) {
                          addressModel.id = widget.address.id;
                          addressModel.userId = widget.address.userId;
                          addressModel.method = 'put';
                          locationProvider.updateAddress(context, addressModel: addressModel, addressId: addressModel.id).then((value) {});
                        } else {
                          locationProvider.addAddress(addressModel, context).then((value) {
                            if (value.isSuccess) {
                              Navigator.pop(context);
                              if (widget.fromCheckout) {
                                Provider.of<LocationProvider>(context, listen: false).initAddressList(context);
                                Provider.of<OrderProvider>(context, listen: false).setAddressIndex(-1);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.message), backgroundColor: Colors.green));
                                Navigator.pop(context);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.message), backgroundColor: Colors.red));
                            }
                          });
                        }
                      }

                    },
                  )
                      : Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      )),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
