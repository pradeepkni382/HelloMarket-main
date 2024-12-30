//
//  ProductDetailScreen.swift
//  hello-market-client
//
//  Created by Mohammad Azam on 9/13/24.
//

import SwiftUI

struct MyProductDetailScreen: View {
    
    let product: Product
    
    @State private var isPresented: Bool = false
    @Environment(ProductStore.self) private var productStore
    
    @Environment(\.dismiss) private var dismiss
    
    private func deleteProduct() async {
        
        do {
            try await productStore.removeProduct(product)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
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
//            AsyncImage(url: product.photoUrl) { img in
//                img.resizable()
//                    .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
//                    .scaledToFit()
//            } placeholder: {
//                ProgressView("Loading...")
//            }
            
            Text(product.name)
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(product.description)
                .padding([.top], 5)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(product.price, format: .currency(code: "USD"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .bold()
                .padding([.top], 2)
            
            Button(role: .destructive) {
                Task {
                    await deleteProduct()
                    dismiss()
                }
            } label: {
                Text("Delete")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .cornerRadius(25)
            }.buttonStyle(.borderedProminent)
            
        }.padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Update") {
                        isPresented = true
                    }
                }
            }
            .sheet(isPresented: $isPresented, content: {
                NavigationStack {
                    AddProductScreen(product: product)
                }
            })
    }
}

#Preview {
    NavigationStack {
        MyProductDetailScreen(product: Product.preview)
    }
    .environment(ProductStore(httpClient: .development))
    .environment(\.uploaderDownloader, ImageUploaderDownloader(httpClient: .development))
    .withMessageView()
}
