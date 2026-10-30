import { IsBoolean, IsOptional, IsString } from 'class-validator';

export class VerifyTransfermovilDto {
  @IsBoolean()
  approved: boolean;

  @IsOptional()
  @IsString()
  notes?: string;
}
