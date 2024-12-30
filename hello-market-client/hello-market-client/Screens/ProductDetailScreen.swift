//
//  ProductDetailScreen.swift
//  hello-market-client
//
//  Created by Mohammad Azam on 9/13/24.
//

import SwiftUI

struct ProductDetailScreen: View {
    
    let product: Product
    @Environment(CartStore.self) private var cartStore
    let step = 1
    let range = 0...5
    @State private var quantity: Int = 0
    
    private func addToCart() async throws {
        
        guard let productId = product.id else {
            throw ProductError.productNotFound  
        }
        if quantity <= 0 { throw ProductError.noItemsSelcted }
        try await cartStore.addItemToCart(productId: productId, quantity: quantity)
    }
    func decrementStep() {
        quantity -= 1
        if quantity < 0 { quantity = quantity - 1 }
    }
    var body: some View {
        ScrollView {
            if let photoPath = product.photoUrl?.path {
                let imageURL = Constants.Urls.base_url.appendingPathComponent(photoPath)
                AsyncImage(url: imageURL) { img in
                    img.resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                    .scaledToFit()
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
            
            
            Text(product.name)
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(product.description)
                .padding([.top], 5)
            Text(product.price, format: .currency(code: "USD"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .bold()
                .padding([.top], 2)
            
            Stepper(value: $quantity,
                    in: range,
                    step: step) {
                Text("Quantity: \(quantity)")
            }
            
            Button {
                Task {
                    do {
                        try await addToCart()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                } label: {
                    Text("Add to cart")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .foregroundColor(.white)
                        .background(.orange)
                        .cornerRadius(25)
                }
               
            
        }.padding()
    }
}

#Preview {
    ProductDetailScreen(product: Product.preview)
        .environment(CartStore(httpClient: .development))
        .withMessageView()
}
