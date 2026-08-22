class ProductFilter {
  final int? storeId;
  final String? storeName;
  final int? categoryId;
  final String? categoryName;
  final double? minPrice;
  final double? maxPrice;
  final bool inStock;
  final String sortBy;
  
  ProductFilter({
    this.storeId,
    this.storeName,
    this.categoryId,
    this.categoryName,
    this.minPrice,
    this.maxPrice,
    this.inStock = false,
    this.sortBy = 'newest',
  });
  
  bool get hasFilters => storeId != null || categoryId != null || minPrice != null || maxPrice != null || inStock;
  
  bool get hasPriceFilter => minPrice != null || maxPrice != null;
  
  String get priceRange {
    if (minPrice != null && maxPrice != null) {
      return '\$${minPrice?.toStringAsFixed(0)} - \$${maxPrice?.toStringAsFixed(0)}';
    } else if (minPrice != null) {
      return '\$${minPrice?.toStringAsFixed(0)}+';
    } else if (maxPrice != null) {
      return 'Up to \$${maxPrice?.toStringAsFixed(0)}';
    }
    return '';
  }
  
  String get sortLabel {
    switch (sortBy) {
      case 'newest':
        return 'Newest';
      case 'price_asc':
        return 'Price: Low to High';
      case 'price_desc':
        return 'Price: High to Low';
      case 'name_asc':
        return 'Name: A to Z';
      case 'name_desc':
        return 'Name: Z to A';
      default:
        return 'Newest';
    }
  }
  
  ProductFilter copyWith({
    int? storeId,
    String? storeName,
    int? categoryId,
    String? categoryName,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    String? sortBy,
  }) {
    return ProductFilter(
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStock: inStock ?? this.inStock,
      sortBy: sortBy ?? this.sortBy,
    );
  }
  
  ProductFilter clearFilters() {
    return ProductFilter(
      storeId: null,
      storeName: null,
      categoryId: null,
      categoryName: null,
      minPrice: null,
      maxPrice: null,
      inStock: false,
      sortBy: sortBy,
    );
  }
  
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (storeId != null) params['store_id'] = storeId.toString();
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();
    if (inStock) params['in_stock'] = 'true';
    params['sort'] = sortBy;
    
    return params;
  }
}
