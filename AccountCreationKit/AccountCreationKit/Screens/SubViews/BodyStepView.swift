//
//  BodyStepView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// Height, weight and date of birth. All three are optional, and each is a row that reads "Not set"
/// until it is set.
///
/// **No wheel is shown until the row is tapped**, deliberately. A wheel always has something under
/// the marker, so an inline picker showing 70 kg would look answered when the user has not answered
/// it — which is the one thing an optional field must not do. Tapping opens a sheet with the wheel
/// and a Clear, and the row goes back to "Not set" when cleared.
///
/// The sheets drive the value live and "Done" only dismisses, the same contract as
/// `SessionSetValueSheet`.
struct BodyStepView: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    @State private var editing: BodyMeasure?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                AccountCreationStepHeader(step: .body)

                VStack(spacing: 10) {
                    BodyMeasurementRow(
                        title: "Height",
                        icon: "ruler",
                        value: heightValue,
                        onTap: { editing = .height }
                    )
                    BodyMeasurementRow(
                        title: "Weight",
                        icon: "scalemass",
                        value: weightValue,
                        onTap: { editing = .weight }
                    )
                    BodyMeasurementRow(
                        title: "Date of Birth",
                        icon: "calendar",
                        value: dateOfBirthValue,
                        onTap: { editing = .dateOfBirth }
                    )
                }

                Text("Weight is the one worth keeping up to date — it's what percentage-of-bodyweight targets are worked out from.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .sheet(item: $editing) { measure in
            switch measure {
            case .height:
                HeightPickerSheet(
                    centimetres: $viewModel.heightCentimetres,
                    unit: $viewModel.heightUnit
                )
                .presentationDetents([.height(420)])
            case .weight:
                WeightPickerSheet(
                    kilograms: $viewModel.weightKilograms,
                    unit: $viewModel.weightUnit
                )
                .presentationDetents([.height(420)])
            case .dateOfBirth:
                DateOfBirthSheet(dateOfBirth: $viewModel.dateOfBirth)
                    .presentationDetents([.height(460)])
            }
        }
    }

    // MARK: - Values

    private var heightValue: String? {
        guard let centimetres = viewModel.heightCentimetres else { return nil }
        return HeightUnit.display(centimetres: centimetres, in: viewModel.heightUnit)
    }

    private var weightValue: String? {
        guard let kilograms = viewModel.weightKilograms else { return nil }
        return BodyWeightUnit.display(kilograms: kilograms, in: viewModel.weightUnit)
    }

    private var dateOfBirthValue: String? {
        guard let dateOfBirth = viewModel.dateOfBirth else { return nil }
        return dateOfBirth.formatted(date: .abbreviated, time: .omitted)
    }
}

#Preview {
    BodyStepView(viewModel: .preview)
}
