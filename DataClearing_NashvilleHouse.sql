use DataCleaning;

SELECT *
FROM nashvillehousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, STR_TO_DATE(SaleDate, '%M%d,%Y')
FROM nashvillehousing;

Update nashvillehousing
Set SaleDate = STR_TO_DATE(SaleDate, '%M%d,%Y');

SELECT *
FROM nashvillehousing;

 --------------------------------------------------------------------------------------------------------------------------

-- Check if any null value in PropertyAddress column

Select *
From nashvillehousing
where PropertyAddress is null; -- All cells are filled

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out OwnerAddress into Individual Columns (Address, City, State)

Select 
	substring_index(OwnerAddress,",",1),
    substring_index(substring_index(OwnerAddress,",",2),",",-1),
    substring_index(OwnerAddress,",",-1)
From nashvillehousing;

Alter Table nashvillehousing
Add OwnerSplitAddress varchar(255);

Update nashvillehousing
Set OwnerSplitAddress = substring_index(OwnerAddress,",",1);

Alter Table nashvillehousing
Add OwnerSplitCity Varchar(255);

Update nashvillehousing
Set OwnerSplitCity = substring_index(substring_index(OwnerAddress,",",2),",",-1);

Alter Table nashvillehousing
Add OwnerSplitState Varchar(255);

Update nashvillehousing
Set OwnerSplitState = substring_index(OwnerAddress,",",-1);

-- Let's check the table
Select *
from nashvillehousing;

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvillehousing
Group by 1
Order by 2;

Select 
	SoldAsVacant,
	Case 
		when SoldAsVacant = 'N' then 'No'
        when SoldAsVacant = 'Y' then 'Yes'
        else SoldAsVacant
        end as SoldAsVacant_update
From nashvillehousing;

Update nashvillehousing
Set SoldAsVacant =
	Case 
		when SoldAsVacant = 'N' then 'No'
        when SoldAsVacant = 'Y' then 'Yes'
        else SoldAsVacant
        end;
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- If ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference are all same, it is duplicate row

WITH CTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From nashvilleHousing
)
Delete nashvilleHousing
From nashvilleHousing
Join CTE
on nashvilleHousing.UniqueID = CTE.UniqueID
Where row_num>1;

Select *
from nashvilleHousing;

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Alter Table nashvilleHousing
Drop column OwnerAddress, 
Drop column PropertyAddress,
Drop column SaleDate;

Select *
from nashvilleHousing;