//
//  MyProductListScreen.swift
//  hello-market-client
//
//  Created by Mohammad Azam on 9/13/24.
//

import SwiftUI

struct MyProductListScreen: View {
    
    @Environment(\.showMessage) private var showMessage
    @Environment(ProductStore.self) private var productStore
    @State private var isPresented: Bool = false
    @AppStorage("userId") private var userId: Int?
    
    private func loadMyProducts() async {
        
        guard let userId = userId else {
            return
        }
        
        do {
            try await productStore.loadMyProducts(by: userId)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        List(productStore.myProducts) { product in
            NavigationLink {
                MyProductDetailScreen(product: product)
            } label: {
                MyProductCellView(product: product)
            }
        }
        .listStyle(.plain)
        .listRowSeparator(.hidden)
        .task {
           await loadMyProducts()
        }.navigationTitle("My Products")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Product") {
                        isPresented = true
                    }
                }
        }
        .sheet(isPresented: $isPresented, content: {
            NavigationStack {
                AddProductScreen()
                    .withMessageView()
            }
        })
        .overlay(alignment: .center) {
            if productStore.myProducts.isEmpty {
                ContentUnavailableView("No products available.", systemImage: "cart")
            }
        }
    }
}

struct MyProductCellView: View {
    
    let product: Product
    
    var body: some View {
        
        HStack(alignment: .top) {
            if let photoPath = product.photoUrl?.path {
                let imageURL = Constants.Urls.base_url.appendingPathComponent(photoPath)
                AsyncImage(url: imageURL) { img in
                    img.resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
                    .frame(width: 100, height: 100)
                } placeholder: {
                    ProgressView("Loading...")
                }
            } else {
                Image(systemName: "gift.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
                    .foregroundColor(.gray)
                    .opacity(0.6)
            }
                Spacer()
                    .frame(width: 20)
                VStack {
                    Text(product.name)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(product.price, format: .currency(code: "USD"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
        }
    }
}

#Preview {
    NavigationStack {
        MyProductListScreen()
    }.environment(ProductStore(httpClient: .development))
}
