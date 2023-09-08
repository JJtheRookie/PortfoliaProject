-- Cleaning Data in SQL Queries


select *
from NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
select saledateconverted, convert(DATE,saledate)
from NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table nashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


----------------------------------------------------------------------------------------------------------------------------------------------------

-- Poplulate Property Address Data

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- Take columns from the same table to compare data insights (Find where the Unique IDS are the same so we can see which address should be under the Nulls)

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Update the table to copy the new column onto the Null Property Address columns

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Invidivual Columns (Address, city, State)

select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

-- Using Substring on PropertyAddress
select
substring(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) as Address
,substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousing

Alter Table nashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = substring(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1)

Alter Table nashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from NashvilleHousing


-- Using Paresname on OwnerAddress

select 
PARSENAME(Replace(OwnerAddress, ',','.'),  3)
,PARSENAME(Replace(OwnerAddress, ',','.'),  2)
,PARSENAME(Replace(OwnerAddress, ',','.'),  1)
from NashvilleHousing


Alter Table nashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),  3)

Alter Table nashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),  2)


Alter Table nashvilleHousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState  = PARSENAME(Replace(OwnerAddress, ',','.'),  1)


----------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and NO in "Sold as Vacant" field

select distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select soldasvacant,
	 case when SoldasVacant = 'Y' THEN 'Yes'
		when soldasvacant = 'N' Then 'No'
		else SoldasVacant
		end
from NashvilleHousing


Update NashvilleHousing
SET  SoldAsVacant = case when SoldasVacant = 'Y' THEN 'Yes'
		when soldasvacant = 'N' Then 'No'
		else SoldasVacant
		end
from NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,	
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID
				) row_num

from NashvilleHousing
--order by ParcelID
)
Select *
from RowNumCTE
where ROW_NUM > 1
order by PropertyAddress


select *
from NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete unused Columns


select *
from NashvilleHousing

Alter Table nashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table nashvilleHousing
Drop Column SaleDate

-- Total value of Type of LandUse vs Avg Price
select landuse, count(landuse) Num_of_Types, sum(TotalValue) Agg_Total, avg(totalvalue) Avg_LandUse_Total
from NashvilleHousing
group by LandUse
order by avg(totalvalue) desc