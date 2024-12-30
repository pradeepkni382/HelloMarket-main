//
//  ProductListScreen.swift
//  hello-market-client
//
//  Created by Mohammad Azam on 9/11/24.
//

import SwiftUI

struct ProductListScreen: View {
    
    @Environment(ProductStore.self) private var productStore
    
    private func loadAllProducts() async {
        do {
            try await productStore.loadAllProducts()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        List(productStore.products) { product in
          
            ZStack {
                ProductCellView(product: product)
                
                NavigationLink(destination: ProductDetailScreen(product: product)) {
                    EmptyView()
                }
                
            }.listRowSeparator(.hidden)
        }
        .refreshable(action: {
            await loadAllProducts()
        })
        .navigationTitle("New Arrivals")
        .listStyle(.plain)
        .task {
           await loadAllProducts()
        }
    }
}

import SwiftUI

import SwiftUI

struct ProductCellView: View {
    
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let photoPath = product.photoUrl?.path {
                let imageURL = Constants.Urls.base_url.appendingPathComponent(photoPath)
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: 150)
                }
            } else {
                Image(systemName: "gift.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
                    .foregroundColor(.gray)
                    .opacity(0.6)
            }
            
            Text(product.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(product.price, format: .currency(code: "USD"))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}



#Preview {
    NavigationStack {
        ProductListScreen()
    } .environment(ProductStore(httpClient: .development))
}
