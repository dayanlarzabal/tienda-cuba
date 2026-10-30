import {
  IsString,
  IsNumber,
  IsOptional,
  IsBoolean,
  IsArray,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateProductDto {
  @IsString()
  name: string;

  @IsString()
  slug: string;

  @IsOptional()
  @IsString()
  description?: string;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  priceCUP: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  priceMLC?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  priceUSDT?: number;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  stock: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  images?: string[];

  @IsOptional()
  @IsString()
  categoryId?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
