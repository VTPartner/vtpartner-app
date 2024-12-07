import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/models/all_goods_types_model.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/global/global.dart' as glb;

class GoodsTypeScreen extends StatefulWidget {
  const GoodsTypeScreen({super.key});

  @override
  State<GoodsTypeScreen> createState() => _GoodsTypeScreenState();
}

class _GoodsTypeScreenState extends State<GoodsTypeScreen> {
  int selectedIndex = 0;
  List<AllGoodsTypesModel> allGoodsTypeModel = [];
  bool isLoading = false;

  Future<void> fetchAllGoodsTypes() async {
    final pref = setState(() {
      isLoading = true;
      allGoodsTypeModel = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/get_all_goods_types', {});
      if (kDebugMode) {
        // print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        List<dynamic> guideLineData = response['results'];
        // Map the list of service data into a list of Service objects
        setState(() {
          allGoodsTypeModel = guideLineData
              .map(
                  (guideLineJson) => AllGoodsTypesModel.fromJson(guideLineJson))
              .toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No Guidelines Found.");
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllGoodsTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  HeadingText(title: 'Select your goods type'),
                ],
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      color: Colors.grey, // Color of the separator
                      thickness: 0.1,
                      indent: 5,
                      endIndent: 5, // Thickness of the separator line
                    );
                  },
                  itemCount: allGoodsTypeModel.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex =
                              index; // Update the selected index on tap.
                        });

                      },
                      child: Ink(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    allGoodsTypeModel[index].goodsTypeName,
                                    style: nunitoSansStyle.copyWith(
                                        color: selectedIndex == index
                                            ? ThemeClass.facebookBlue
                                            : Colors.black,
                                        fontSize: 14.0),
                                  ),
                                  // selectedIndex == index
                                  //     ? Text(
                                  //         "Quantity: Loose",
                                  //         style: nunitoSansStyle.copyWith(
                                  //             color: Colors.grey,
                                  //             fontSize: 12.0),
                                  //       )
                                  //     : SizedBox()
                                ],
                              ),
                              selectedIndex == index
                                  ? Icon(
                                      Icons.check,
                                      color: ThemeClass.facebookBlue,
                                    )
                                  : SizedBox()
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            )),
            SizedBox(
              height: 100,
            )
          ],
        ),
        bottomSheet: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    var goodsTypeID =
                        allGoodsTypeModel[selectedIndex].goodsTypeId;
                    var goodsTypeName =
                        allGoodsTypeModel[selectedIndex].goodsTypeName;
                    AssistantMethods.saveGoodsTypeDetails(
                        goodsTypeID, goodsTypeName, context);
                    Navigator.pop(context);
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                          image: AssetImage("assets/images/buttton_bg.png"),
                          fit: BoxFit.cover),
                      color: ThemeClass.facebookBlue,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Update',
                                style: nunitoSansStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.fontSize,
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
