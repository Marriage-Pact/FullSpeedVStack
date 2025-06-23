#  README

/// When it's an enum with an associated value, make sure that value that is in `hash(into)` is that associated value.
/*
 func hash(into hasher: inout Hasher) {
    switch self {
        case .topLine(let viewModel):
            hasher.combine(viewModel)
 */
/// Also completely fill-out the switch statement for the `static func ==`
/*
 static func == (lhs: ProfileCellViewModel, rhs: ProfileCellViewModel) -> Bool {
    switch (lhs, rhs) {
        case (.topLine(let lhsViewModel), .topLine(let rhsViewModel)):
        return lhsViewModel == rhsViewModel
 */
