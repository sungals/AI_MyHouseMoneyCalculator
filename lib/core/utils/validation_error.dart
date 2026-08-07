/// 입력 검증 실패 사유. 표시 문장은 표현 계층이 지역화한다.
enum ValidationError {
  amountRequired,
  amountInvalid,
  rateRequired,
  rateOutOfRange,
  monthsRequired,
  monthsOutOfRange,
  loanExceedsDeposit,
}
